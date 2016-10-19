import Foundation
import Dispatch

public class Connection {
    var socket: SocketWrapper
    var host: String
    var port: Int32
    var db: String
    var user: String
    var password: String
    var handshake: Handshake
    var dispatchError: Error?
    var responseQueue: DispatchQueue
    var queryQueue: DispatchQueue
    var lockQueue: DispatchQueue
    var waiters: [UInt64: DispatchSemaphore]
    var completedQueries: [UInt64: Response]
    // var cursorCache: [UInt64: Cursor<Any>]
    var isOpen: Bool
    var nextToken: UInt64 = 1

    init(host: String = "localhost", port: Int32 = 28015, db: String = "", user: String = "admin", password: String = "", authKey: String = "", version: ProtocolVersion = .v1_0) throws {
        self.host = host
        self.port = port
        self.db = db
        self.user = user
        self.password = password
        self.responseQueue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.response")
        self.queryQueue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.query")
        self.lockQueue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.lock")
        self.waiters = [:]
        self.completedQueries = [:]
        // self.cursorCache = [:]
        self.socket = try SocketWrapper(host: self.host, port: self.port)
        self.isOpen = false

        switch version {
        case .v0_4:
            self.handshake = try HandshakeV0_4(authKey: authKey)
        case .v1_0:
            self.handshake = try HandshakeV1_0(user: user, password: password)
        }
    }

    deinit {
        self.close()
    }

    public func connect() throws {
        try socket.connect(self.handshake)
        self.isOpen = true

        // Asynchronously read responses from the server
        self.responseQueue.async {
            while self.isOpen {
                if !self.socket.isOpen {
                    self.dispatchError = ReqlError.driverError("Connection to server was unexpectedly closed.")
                    break
                }

                do {
                    let response = try self.socket.readResponse()
                    self.completedQueries[response.token] = response

                    // get response for waiting query and signal waiter
                    if let waiter = self.waiters.removeValue(forKey: response.token) {
                        waiter.signal()
                    }
                } catch let e {
                    if self.isOpen {
                        self.dispatchError = e
                    }
                    break
                }
            }
        }
    }

    public func close() {
        if !self.isOpen {
            return
        }

        self.isOpen = false
        self.socket.close()
        if let error = self.dispatchError {
            // handle the error
            fatalError("Error: \(error)")
        }
    }
    
    public func use(_ db: String) {
        self.db = db
    }

    func sendQuery(_ query: Query) throws -> DispatchSemaphore {
        return try self.sendQuery(query, noReply: false)
    }

    func sendQuery(_ query: Query, noReply: Bool) throws -> DispatchSemaphore {
        if !self.isOpen {
            throw ReqlError.driverError("Cannot write query because connection is closed.")
        }

        let writeQuery = {
            do {
                try self.socket.writeQuery(query)
            } catch let error {
                self.dispatchError = error
            }
        }
        
        let waiter = DispatchSemaphore(value: 0)
        self.waiters[query.token] = waiter
        
        self.queryQueue.async(execute: writeQuery)
        return waiter
    }

    func runQuery<T>(_ query: Query, noReply: Bool) throws -> T {
        if noReply {
            _ = try self.sendQuery(query, noReply: noReply)
            guard let empty = Response.empty as? T else {
                throw ReqlError.driverError("Cannot return value of suggested type.")
            }
            return empty
        }

        try self.sendQuery(query).wait()

        guard let response = self.completedQueries.removeValue(forKey: query.token) else {
            throw ReqlError.driverError("No response from query")
        }
        
        guard let result: T = try response.unwrap(query, connection: self) else {
            throw ReqlError.driverError("Cannot return value of suggested type.")
        }
        
        return result
    }
    
    func runQueryNoReply(_ query: Query) throws {
        _ = try self.sendQuery(query, noReply: true)
    }

    func run<T>(_ term: Any, options: OptArgs<GlobalArg>) throws -> T {
        if !options.contains(key: "db") && self.db != "" {
            options.setArg(.db(ReqlQueryDatabase(name: self.db)))
        }
        
        let noReply = options.get(key: "noreply") ?? false
        let query = try Query.start(self.newToken(), term: term, globalOptions: options)
        return try self.runQuery(query, noReply: noReply)
    }
    
    func runNoReply(_ term: Any, options: OptArgs<GlobalArg>) throws {
        options.setArg(.noReply(true))
        if !options.contains(key: "db") && self.db != "" {
            options.setArg(.db(ReqlQueryDatabase(name: self.db)))
        }
        
        let query = try Query.start(self.newToken(), term: term, globalOptions: options)
        try self.runQueryNoReply(query)
    }

    func sendContinue<T>(_ cursor: Cursor<T>) throws -> DispatchSemaphore {
        return try self.sendQuery(try Query.continueQuery(cursor.token))
    }

    func stop<T>(_ cursor: Cursor<T>) throws {
        let _: Any = try self.runQuery(Query.stop(cursor.token), noReply: true)
    }

    func noreplyWait() throws {
        let _: Bool = try self.runQuery(Query.noReplyWait(self.newToken()), noReply: false)
    }
    
    func server() throws -> Document {
        guard let info: Document = try self.runQuery(Query.serverInfo(self.newToken()), noReply: false) else {
            throw ReqlError.driverError("Could not get server info.")
        }
        return info
    }

    func newToken() -> UInt64 {
        var token: UInt64 = 0
        lockQueue.sync {
            token = nextToken
            self.nextToken += 1
        }
        return token
    }
}
