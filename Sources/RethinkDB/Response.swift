import Foundation
import WarpCore

open class Response {

    public enum ResponseType: Int {
        case empty = 0
        case atom = 1
        case sequence = 2
        case partial = 3
        case waitComplete = 4
        case serverInfo = 5
        case clientError = 16
        case compileError = 17
        case runtimeError = 18
    }

    public enum ResponseNote: Int {
        case sequenceFeed = 1
        case atomFeed = 2
        case orderByLimitFeed = 3
        case unionedFeed = 4
        case includesStates = 5
    }

    var type: ResponseType
    var rawResult: [Any]
    var documents: [Document]
    var notes: [ResponseNote]
    var backtrace: [Any]?
    var profile: [Any]?
    var token: UInt64
    var isFeed: Bool {
        return self.notes.contains { (note: ResponseNote) -> Bool in  
            return note == .sequenceFeed ||
                   note == .atomFeed ||
                   note == .orderByLimitFeed ||
                   note == .unionedFeed
        }
    }
    
    static var empty: Response {
        return Response()
    }
    
    init() {
        self.type = .empty
        self.rawResult = []
        self.documents = []
        self.notes = []
        self.token = .min
    }

    init(data: Data, token: UInt64) throws {
        guard let json = try JSON.from(data).decode() as? [String: Any] else {
            throw ReqlError.driverError("Invalid JSON response.")
        }

        guard let typeRawValue = json["t"] as? Int64 else {
            throw ReqlError.driverError("Invalid JSON response. Could get `type` value.")
        }

        guard let type = ResponseType(rawValue: Int(typeRawValue)) else {
            throw ReqlError.driverError("Invalid response type.")
        }

        self.type = type
        self.rawResult = json["r"] as? [Any] ?? []
        self.documents = [Document](array: self.rawResult) //as? [ValueConvertible] ?? []).map { Value($0) }
        self.backtrace = json["b"] as? [Any]
        self.profile = json["p"] as? [Any]

        var notes = [ResponseNote]()
        if let notesArray = json["n"] as? [Any] {
            notesArray.forEach { note in
                if let noteRawValue = note as? Int, let note = ResponseNote(rawValue: noteRawValue) {
                    notes.append(note)
                }
            }
        }
        self.notes = notes

        self.token = token
    }
    
    func unwrap<T>(_ query: Query, connection: Connection) throws -> T? {
        switch self.type {
        case .atom, .serverInfo:
            let atom = self.rawResult[0]
            let unwrapped = self.unwrapAtom(atom)
            if let doc = Document(element: unwrapped) as? T {
                return doc
            }
            
            if let writeResult = WriteResult(element: unwrapped) as? T {
                return writeResult
            }
            
            return unwrapped as? T
        case .sequence, .partial:
            return Cursor<Document>(connection: connection, query: query, firstResponse: self, transform: { $0 }) as? T
        case .waitComplete:
            return true as? T
        default:
            throw self.makeError(query)
        }
    }
    
    func unwrapAtom(_ atom: Any) -> Any {
        if let dict = atom as? [String: Any] {
            if let reqlTypeRaw = dict[ReqlType.key] as? String,
                let reqlType = ReqlType(rawValue: reqlTypeRaw) {
                switch reqlType {
                case .time:
                    return Date.from(dict)
                case .binary:
                    return Data.from(dict)
                case .geometry:
                    if let geometry = Geometry.from(dict) {
                        return geometry
                    }
                }
            }
            
            return Document(element: dict)
        }
        
        if let arr = atom as? [Any] {
            return arr.map({ self.unwrapAtom($0) })
        }
        
        return atom
    }

    func makeError(_ query: Query) -> ReqlError {
        guard let error = self.rawResult[0] as? String else {
            return ReqlError.driverError("Invalid JSON for result in response.")
        }
        
        var errorType: String = ""
        if self.type == .clientError {
            errorType = "Client Error"
        } else if self.type == .compileError {
            return ReqlError.compileError(error, query.term, self.backtrace ?? [])
        } else if self.type == .runtimeError {
            errorType = "Runtime Error"
        }

        return ReqlError.driverError("Error in response: \(errorType) - \(error) - \(query.data)")
    }
}
