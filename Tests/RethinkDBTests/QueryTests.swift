#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import XCTest
@testable import RethinkDB

func randInt(_ upperBound: Int) -> Int {
    #if os(Linux)
        return Int(random() % (upperBound + 1))
    #else
        return Int(arc4random_uniform(UInt32(upperBound)))
    #endif
}

class QueryTests: BaseTests {
    
    var ids: [String] = []
    
    override func setUp() {
        super.setUp()
        
        do {
            let conn = try r.connect(host: Tests.host)
            var locations: [Document] = []
            for _ in 0..<25 {
                let loc: Document = ["lat": Double(randInt(180)) - 90, "long": Double(randInt(180))]
                locations.append(loc)
            }
            
            guard let _: Document = try r.db("test").table("locations").insert(locations).run(conn) else {
                XCTFail("Failure to insert data.")
                return
            }
        } catch let error {
            XCTFail("Failure: \(error)")
        }
    }
    
    func testQueryTable() throws {
        let conn = try r.connect(host: Tests.host)
        guard let locations: Cursor<Document> = try r.db("test").table("locations").run(conn) else {
            XCTFail("`locations` is not a `Cursor`.")
            return
        }

        for location in locations {
            guard location["id"].stringValue != nil else {
                XCTFail("`id` is not a `String`")
                return
            }

            guard location["lat"].doubleValue != nil else {
                XCTFail("`lat` is not an `Double`")
                return
            }

            guard location["long"].doubleValue != nil else {
                XCTFail("`long` is not an `Double`")
                return
            }
        }
    }
    
    func testDefaultDBQuery() throws {
        let conn = try r.connect(host: Tests.host)
        guard let _: Cursor<Document> = try r.table("calendar").run(conn) else {
            XCTFail("Could not get calendar")
            return
        }
    }
    
    func testQueryNoReply() throws {
        let conn = try r.connect(host: Tests.host)
        try r.db("test").table("locations").runNoReply(conn)
        try conn.noreplyWait()
    }

    static var allTests : [(String, (QueryTests) -> () throws -> Void)] {
        return [
            ("testQueryTable", testQueryTable),
            ("testDefaultDBQuery", testDefaultDBQuery),
            ("testQueryNoReply", testQueryNoReply)
        ]
    }
}
