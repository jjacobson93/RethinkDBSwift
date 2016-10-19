#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import XCTest
@testable import RethinkDB

let r = RethinkDB.r

class BaseTests: XCTestCase {
    static var testsCount: Int = 0
    
    class var host: String {
        guard let rawValue = getenv("RETHINKDB_HOST") else {
            return "localhost"
        }
        
        return String(utf8String: rawValue) ?? "localhost"
    }
    
    override class func setUp() {
        super.setUp()
        BaseTests.testsCount += 1

        do {
            let conn = try r.connect(host: host)
            let dbs: [String] = try r.dbList().run(conn)
            if !dbs.contains("galaxy") {
                let _: Document = try r.dbCreate("galaxy").run(conn)
            }
            
            let galaxyTables: [String] = try r.db("galaxy").tableList().run(conn)
            
            if !galaxyTables.contains("systems") {
                let _: Document = try r.db("galaxy").tableCreate("systems").run(conn)
            }
            
            let tables: [String] = try r.db("test").tableList().run(conn)
            
            if !tables.contains("locations") {                
                let _: Document = try r.db("test").tableCreate("locations").run(conn)
            }
            
            if !tables.contains("calendar") {
                let _: Document = try r.db("test").tableCreate("calendar").run(conn)
            }

            if !tables.contains("files") {
                let _: Document = try r.db("test").tableCreate("files").run(conn)
            }
            
            if !tables.contains("contacts") {
                let _: Document = try r.db("test").tableCreate("contacts").run(conn)
            }
        } catch let error {
            fatalError("Failure setting up: \(error)")
        }
    }
    
    override class func tearDown() {
        super.tearDown()
        BaseTests.testsCount -= 1

        if BaseTests.testsCount != 0 {
            return
        }
        
        do {
            let conn = try r.connect(host: host)
            let dbs: [String] = try r.dbList().run(conn)
            
            if dbs.contains("galaxy") {
                let _: Document = try r.dbDrop("galaxy").run(conn)
            }
            
            let tables: [String] = try r.db("test").tableList().run(conn)
            
            if tables.contains("locations") {
                let _: Document = try r.db("test").tableDrop("locations").run(conn)
            }
            
            if tables.contains("calendar") {
                let _: Document = try r.db("test").tableDrop("calendar").run(conn)
            }
            
            if tables.contains("files") {
                let _: Document = try r.db("test").tableDrop("files").run(conn)
            }
            
            if tables.contains("contacts") {
                let _: Document = try r.db("test").tableDrop("contacts").run(conn)
            }
        } catch let error {
            fatalError("Failure tearing down: \(error)")
        }
    }
}
