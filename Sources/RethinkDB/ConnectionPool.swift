//
// Created by Jeremy Jacobson on 3/27/17.
//

import Foundation
import SSLService
import Dispatch

public class ConnectionPool {
    var size: Int

    var connections: [Connection]
    var free: [Connection]
    var host: String
    var port: Int32
    var db: String
    var user: String
    var password: String
    var version: ProtocolVersion
    var sslConfig: SSLService.Configuration?

    // Dispatch
    var waiters: [DispatchSemaphore]
    let lockQueue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.poolLockQueue")
    let closeQueue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.closeQueue")

    init(size: Int = 10,
         host: String = "localhost",
         port: Int32 = 28015,
         db: String = "",
         user: String = "admin",
         password: String = "",
         version: ProtocolVersion = .v1_0,
         sslConfig: SSLService.Configuration? = nil) {
        self.size = size
        self.connections = []
        self.free = []
        self.host = host
        self.port = port
        self.db = db
        self.user = user
        self.password = password
        self.version = version
        self.sslConfig = sslConfig
        self.waiters = []
    }

    func connect() throws {
        try self.resize(to: self.size)
    }

    func close() {
        if self.connections.count == 0 {
            return
        }
        
        let group = DispatchGroup()
        while let conn = self.connections.popLast() {
            self.closeConnection(conn, group: group)
        }
        
        group.wait()
    }

    func addConnection() throws {
        let conn = try Connection(host: self.host,
                port: self.port,
                db: self.db,
                user: self.user,
                password: self.password,
                version: self.version,
                sslConfig: self.sslConfig)
        try conn.connect()
        self.connections.append(conn)
        self.free.append(conn)
    }

    func closeConnection(_ conn: Connection, group: DispatchGroup) {
        group.enter()
        self.closeQueue.async {
            conn.close(waitForResponses: true)
            group.leave()
        }
    }

    func resize(to newSize: Int) throws {
        // add connections
        if self.connections.count < newSize {
            let add = newSize - self.connections.count
            for _ in 0..<add {
                try self.addConnection()
            }
        } else if self.connections.count > newSize { // remove connections
            let remove = self.connections.count - newSize
            let group = DispatchGroup()
            for _ in 0..<remove {
                // remove from the end
                if let conn = self.connections.popLast() {
                    self.closeConnection(conn, group: group)
                }
            }
            
            group.wait()
        }

        self.size = newSize
    }

    /**
        Acquires a connection from the pool.

        - Parameter timeout: A timeout in seconds

        - Throws: `ReqlError.driverError` if `timeout` is specified and it
            times out waiting for a connection

        - Returns: A `Connection` from the pool
    */
    public func acquire(timeout: Int? = nil) throws -> Connection {
        var conn: Connection!
        try self.lockQueue.sync {
            if free.count == 0 {
                let waiter = DispatchSemaphore(value: 0)
                self.waiters.append(waiter)

                // wait for a connection to free up
                if let timeout = timeout {
                    let result = waiter.wait(timeout: DispatchTime.now() + .seconds(timeout))
                    if case .timedOut = result {
                        throw ReqlError.driverError("Timed out attempting to acquire a connection from the pool.")
                    }
                } else {
                    waiter.wait()
                }
            }

            conn = self.free.popLast()
        }

        return conn
    }

    /**
        Release the `connection`
        
        - Parameter connection: The connection to release back to the pool
    */
    public func release(connection: Connection) {
        self.free.append(connection)
        if self.waiters.count > 0 {
            let waiter = self.waiters.remove(at: 0)
            waiter.signal()
        }
    }

    deinit {
        self.close()
    }
}
