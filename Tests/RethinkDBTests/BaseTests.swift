#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import XCTest
@testable import RethinkDB

let r = RethinkDB.r

class Tests {
    static var count: Int = 0
    static var dbs: [String: [String]] = [
        "galaxy": ["systems", "stars", "planets"],
        "test": ["locations", "calendar", "files", "contacts"]
    ]
    
    static var dummyData: [String: [String: [Document]]] = [
        "galaxy": [
            "systems": [
                ["name": "Sol", "distanceFromEarth": 1.581e-5, "stars": ["Sol"]],
                ["name": "Gliese 581", "distanceFromEarth": 20.22, "stars": ["Gliese 581"]],
                ["name": "Sirius", "distanceFromEarth": 8.611, "stars": ["Sirius A", "Sirius B"]],
            ],
            "stars": [
                ["name": "Sol", "mass": 1],
                ["name": "Gliese 581", "mass": 0.31],
                ["name": "Sirius A", "mass": 2.02],
                ["name": "Sirius B", "mass": 0.978]
            ]
        ]
    ]
    
    static var indices: [String: [String: [String]]] = [
        "galaxy": [
            "systems": ["name"],
            "stars": ["name"]
        ]
    ]
    
    static var host: String = ({ _ in
        let defaultHost = "localhost"
        guard let rawValue = getenv("RETHINKDB_HOST") else {
            return defaultHost
        }
        
        return String(utf8String: rawValue) ?? defaultHost
    })()
    
    static func setUp() {
        Tests.count += 1
        if self.count > 1 {
            return
        }
        
        do {
            let conn = try r.connect(host: Tests.host)
            let dbList: [String] = try r.dbList().run(conn)
            for (db, tables) in Tests.dbs {
                if !dbList.contains(db) {
                    let _: Document = try r.dbCreate(db).run(conn)
                }
                
                let dbData = Tests.dummyData[db]
                let dbIndices = Tests.indices[db]
                
                let tableList: [String] = try r.db(db).tableList().run(conn)
                for table in tables {
                    if !tableList.contains(table) {
                        let _: Document = try r.db(db).tableCreate(table).run(conn)
                    }
                    
                    if let tableIndices = dbIndices?[table] {
                        let indexList: [String] = try r.db(db).table(table).indexList().run(conn)
                        for index in tableIndices {
                            if !indexList.contains(index) {
                                let _: Document = try r.db(db).table(table).indexCreate(index).run(conn)
                            }
                        }
                        
                        let _: Document = try r.db(db).table(table).indexWait().run(conn)
                    }
                    
                    if let docs = dbData?[table] {
                        let _: WriteResult = try r.db(db).table(table).insert(docs).run(conn)
                    }
                    
                }
            }
        } catch let error {
            fatalError("Failure setting up: \(error)")
        }
    }
    
    static func tearDown() {
        Tests.count -= 1
        if Tests.count != 0 {
            return
        }
        
        do {
            let conn = try r.connect(host: Tests.host)
            let dbList: [String] = try r.dbList().run(conn)
            for db in dbList {
                if let _ = Tests.dbs[db] {
                    let _: Document = try r.dbDrop(db).run(conn)
                }
            }
        } catch let error {
            fatalError("Failure tearing down: \(error)")
        }
    }
}

class BaseTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        Tests.setUp()
    }
    
    override class func tearDown() {
        super.tearDown()
        Tests.tearDown()
    }
}
