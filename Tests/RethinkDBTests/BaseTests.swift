#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import XCTest
import SSLService
@testable import RethinkDB

let r = RethinkDB.r

class Tests {
    static var count: Int = 0
    static var dbs: [String: [String]] = [
        "galaxy": ["systems", "stars", "planets", "systemTypes"],
        "test": ["locations", "calendar", "files", "contacts"]
    ]
    
    static var dummyData: [String: [String: [Document]]] = [
        "galaxy": [
            "systems": [
                ["name": "Sol", "distanceFromEarth": 1.581e-5, "stars": ["Sol"], "type": "A"],
                ["name": "Gliese 581", "distanceFromEarth": 20.22, "stars": ["Gliese 581"], "type": "C"],
                ["name": "Sirius", "distanceFromEarth": 8.611, "stars": ["Sirius A", "Sirius B"], "type": "B"],
            ],
            "stars": [
                ["name": "Sol", "mass": 1],
                ["name": "Gliese 581", "mass": 0.31],
                ["name": "Sirius A", "mass": 2.02],
                ["name": "Sirius B", "mass": 0.978]
            ],
            "systemTypes": [
                ["name": "A"], ["name": "B"], ["name": "C"],
            ]
        ]
    ]
    
    static var indices: [String: [String: [String]]] = [
        "galaxy": [
            "systems": ["name", "type"],
            "stars": ["name"],
            "systemTypes": ["name"]
        ]
    ]
    
    static var host: String = ({ _ in
        let defaultHost = "localhost"
        guard let rawValue = getenv("RETHINKDB_HOST") else {
            return defaultHost
        }
        
        return String(utf8String: rawValue) ?? defaultHost
    })()
    
    static var keyFile: String? = ({
        guard let rawValue = getenv("KEY_FILE") else {
            return nil
        }
        
        return String(utf8String: rawValue)
    })()
    
    static var certFile: String? = ({
        guard let rawValue = getenv("CERT_FILE") else {
            return nil
        }
        
        return String(utf8String: rawValue)
    })()
    
    static var caFile: String? = ({
        guard let rawValue = getenv("CA_FILE") else {
            return nil
        }
        
        return String(utf8String: rawValue)
    })()
    
    static var chainFile: String? = ({
        guard let rawValue = getenv("CHAIN_FILE") else {
            return nil
        }
        
        return String(utf8String: rawValue)
    })()
    
    static var sslConfig: SSLService.Configuration? = ({
        // #if os(Linux)
        //     return SSLService.Configuration(withCACertificateDirectory: nil, usingCertificateFile: Tests.certFile, withKeyFile: Tests.keyFile)
        // #else
        //     return SSLService.Configuration(withChainFilePath: Tests.chainFile, withPassword: "Test")
        // #endif
        return nil
    })()
    
    static var protectedUserPassword = "testing123"
    
    static func setUp() {
        Tests.count += 1
        if self.count > 1 {
            return
        }
        
        do {
            let conn = try r.connect(host: Tests.host, ssl: Tests.sslConfig)
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
            
            // add user with password for testing
            let _: Document = try r.db("rethinkdb").table("users").insert([
                "id": "protected_user",
                "password": Tests.protectedUserPassword
            ]).run(conn)
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
            let conn = try r.connect(host: Tests.host, ssl: Tests.sslConfig)
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
    var conn: Connection {
        return try! r.connect(host: Tests.host, ssl: Tests.sslConfig)
    }
    
    override class func setUp() {
        super.setUp()
        Tests.setUp()
    }
    
    override class func tearDown() {
        super.tearDown()
        Tests.tearDown()
    }
    
    deinit {
        self.conn.close()
    }
}
