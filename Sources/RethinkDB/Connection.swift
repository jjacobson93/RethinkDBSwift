import Foundation
import Dispatch
import SSLService

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
    var tokenLockQueue: DispatchQueue
    var acceptQueriesLockQueue: DispatchQueue
    var waiters: [UInt64: DispatchSemaphore]
    var completedQueries: [UInt64: Response]
    // var cursorCache: [UInt64: Cursor<Any>]
    var isOpen: Bool
    var acceptQueries: Bool
    var nextToken: UInt64 = 1

    var isAcceptingQueries: Bool {
        var value: Bool = false
        self.acceptQueriesLockQueue.sync {
            value = self.acceptQueries
        }
        return value
    }

    init(host: String = "localhost",
         port: Int32 = 28015,
         db: String = "",
         user: String = "admin",
         password: String = "",
         authKey: String = "",
         version: ProtocolVersion = .v1_0,
         sslConfig: SSLService.Configuration? = nil) throws {
        self.host = host
        self.port = port
        self.db = db
        self.user = user
        self.password = password
        self.responseQueue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.response")
        self.queryQueue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.query")
        self.tokenLockQueue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.tokenLock")
        self.acceptQueriesLockQueue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.acceptQueriesLock")
        self.waiters = [:]
        self.completedQueries = [:]
        // self.cursorCache = [:]
        self.socket = try SocketWrapper(host: self.host, port: self.port, sslConfig: sslConfig)
        self.isOpen = false
        self.acceptQueries = false

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
        self.acceptQueries = true

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

    public func close(waitForResponses: Bool = false) {
        if waitForResponses {
            self.acceptQueries = false
            for waiter in self.waiters.values {
                waiter.wait()
            }
        }

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

        if !self.isAcceptingQueries {
            throw ReqlError.driverError("Cannot accept queries. Driver is in the process of closing and waiting for responses to be received.")
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
                throw ReqlError.typeError("Empty", String(describing: T.self))
            }
            return empty
        }

        try self.sendQuery(query).wait()

        guard let response = self.completedQueries.removeValue(forKey: query.token) else {
            throw ReqlError.driverError("No response from query")
        }

        return try response.unwrap(query, connection: self)
    }

    func runQuery<T: ExpressibleByNilLiteral>(_ query: Query, noReply: Bool) throws -> T {
        if noReply {
            _ = try self.sendQuery(query, noReply: noReply)
            guard let empty = Response.empty as? T else {
                throw ReqlError.typeError("Empty", String(describing: T.self))
            }
            return empty
        }

        try self.sendQuery(query).wait()

        guard let response = self.completedQueries.removeValue(forKey: query.token) else {
            throw ReqlError.driverError("No response from query")
        }

        return try response.unwrap(query, connection: self)
    }
    
    func runQueryNoReply(_ query: Query) throws {
        _ = try self.sendQuery(query, noReply: true)
    }

    func setupRunQuery(_ term: [Any], options: OptArgs<GlobalArg>) throws -> (query: Query, noReply: Bool) {
        if !options.contains(key: "db") && self.db != "" {
            options.setArg(.db(ReqlQueryDatabase(name: self.db)))
        }

        let noReply = options.get(key: "noreply") ?? false
        let query = try Query.start(self.newToken(), term: term, globalOptions: options)
        return (query: query, noReply: noReply)
    }

    func run<T>(_ term: [Any], options: OptArgs<GlobalArg>) throws -> T {
        let (query, noReply) = try self.setupRunQuery(term, options: options)
        return try self.runQuery(query, noReply: noReply)
    }

    func run<T: ExpressibleByNilLiteral>(_ term: [Any], options: OptArgs<GlobalArg>) throws -> T {
        let (query, noReply) = try self.setupRunQuery(term, options: options)
        return try self.runQuery(query, noReply: noReply)
    }
    
    func runNoReply(_ term: [Any], options: OptArgs<GlobalArg>) throws {
        options.setArg(.noReply(true))
        let (query, _) = try self.setupRunQuery(term, options: options)
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
        self.tokenLockQueue.sync {
            token = nextToken
            self.nextToken += 1
        }
        return token
    }
}
