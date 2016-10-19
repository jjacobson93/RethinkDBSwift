import Foundation
import JSON

enum ReqlQueryType: Int {
    case start =  1
    case `continue` = 2
    case stop =  3
    case noReplyWait = 4
    case serverInfo = 5
}

class Query {
    var token: UInt64
    var term: Any
    var data: Data
    var globalOptions: OptArgs<GlobalArg>
    var isNoReply: Bool {
        return self.globalOptions.get(key: "noreply") ?? false
    }

    init(type: ReqlQueryType, token: UInt64, term: Any, globalOptions: OptArgs<GlobalArg>) throws {
        self.globalOptions = globalOptions
        let json = [type.rawValue, term, globalOptions.json]
        self.data = try JSON.data(with: json) //JSONSerialization.data(withJSONObject: json, options: [])
        self.term = term
        self.token = token
    }

    static func start(_ token: UInt64, term: Any, globalOptions: OptArgs<GlobalArg>) throws -> Query {
        return try Query(type: .start, token: token, term: term, globalOptions: globalOptions)
    }

    static func stop(_ token: UInt64) throws -> Query {
        return try Query(type: .stop, token: token, term: [], globalOptions: OptArgs<GlobalArg>([]))
    }

    static func continueQuery(_ token: UInt64) throws -> Query {
        return try Query(type: .continue, token: token, term: [], globalOptions: OptArgs<GlobalArg>([]))
    }

    static func noReplyWait(_ token: UInt64) throws -> Query {
        return try Query(type: .noReplyWait, token: token, term: [], globalOptions: OptArgs<GlobalArg>([]))
    }
    
    static func serverInfo(_ token: UInt64) throws -> Query {
        return try Query(type: .serverInfo, token: token, term: [], globalOptions: OptArgs<GlobalArg>([]))
    }
}
