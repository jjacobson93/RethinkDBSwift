import XCTest
@testable import RethinkDB

class InsertTests: BaseTests {
    func testInsertOne() throws {
        let doc: Document = ["lat": 100, "long": 10]
        guard let result: Document = try r.db("test").table("locations").insert(doc).run(conn) else {
            XCTFail("Could not insert document.")
            return
        }

        guard let generatedKeys = result["generated_keys"].arrayValue else {
            XCTFail("Generated keys is not an array.")
            return
        }

        guard let id = generatedKeys[0].stringValue else {
            XCTFail("`id` is not a string.")
            return
        }

        print("ID: \(id)")
        print("Result: \(result)")
    }
    
    func testInsertMultiple() throws {
        let docs: [Document] = [
            ["lat": 180, "long": 80], ["lat": 47, "long": 75], ["lat": 29, "long": 84]
        ]
        guard let result: Document = try r.db("test").table("locations").insert(docs).run(conn) else {
            XCTFail("Could not insert documents.")
            return
        }
        
        guard let generatedKeys = result["generated_keys"].arrayValue else {
            XCTFail("Generated keys is not an array.")
            return
        }
        
        XCTAssert(generatedKeys.count == 3, "Expected 3 generated keys, found \(generatedKeys.count)")
    }

    static var allTests : [(String, (InsertTests) -> () throws -> Void)] {
        return [
            ("testInsertOne", testInsertOne),
            ("testInsertMultiple", testInsertMultiple)
        ]
    }
}
