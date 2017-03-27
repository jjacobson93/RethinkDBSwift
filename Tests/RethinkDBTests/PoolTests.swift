//
//  PoolTests.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 3/27/17.
//
//

import XCTest
import Dispatch
@testable import RethinkDB

class PoolTests: BaseTests {
    func testConnect() throws {
        let pool = try r.pool(host: Tests.host, ssl: Tests.sslConfig)
        pool.close()
    }
    
    func testAcquire() throws {
        let pool = try r.pool(size: 1, host: Tests.host, ssl: Tests.sslConfig)
        let conn = try pool.acquire()
        pool.release(connection: conn)
        pool.close()
    }
    
    func testAcquireWait() throws {
        let pool = try r.pool(size: 1, host: Tests.host, ssl: Tests.sslConfig)
        let queue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.testAcquireWait")
        let conn = try pool.acquire()
        
        // hold onto the connection for 2 seconds
        queue.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) { 
            pool.release(connection: conn)
        }
        
        let conn2 = try pool.acquire(timeout: 3)
        pool.release(connection: conn2)
        pool.close()
    }
    
    func testAcquireTimeout() throws {
        let pool = try r.pool(size: 1, host: Tests.host, ssl: Tests.sslConfig)
        let queue = DispatchQueue(label: "io.jjacobson.swift.RethinkDB.testAcquireWait")
        let conn = try pool.acquire()
        
        // hold onto the connection for 2 seconds
        queue.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            pool.release(connection: conn)
        }
        
        do {
            let conn2 = try pool.acquire(timeout: 1)
            pool.release(connection: conn2)
            XCTFail("Acquired the connection")
        } catch let error as ReqlError {
            XCTAssertEqual(error.localizedDescription, "Timed out attempting to acquire a connection from the pool.")
        }
        pool.close()
    }
    
    static var allTests : [(String, (PoolTests) -> () throws -> Void)] {
        return [
            ("testConnect", testConnect),
            ("testAcquire", testAcquire),
            ("testAcquireWait", testAcquireWait),
            ("testAcquireTimeout", testAcquireTimeout)
        ]
    }
}
