import Foundation
import XCTest
@testable import RethinkDB

let ONE_DAY = TimeInterval(8640) //s

class PseudoTypesTests: BaseTests {
    func testInsertDate() throws {
        let conn = try r.connect(host: BaseTests.host)
        let doc: Document = ["title": "Dinner Date", "time": Date() + ONE_DAY]
        let result: WriteResult = try r.db("test").table("calendar").insert(doc).run(conn)

        XCTAssert(result.generatedKeys.count == 1, "Expected generatedKeys to contain 1, found \(result.generatedKeys.count)")
    }

    func testQueryDate() throws {
        let conn = try r.connect(host: BaseTests.host)
        let events: Cursor<Document> = try r.db("test").table("calendar").run(conn)

        for event in events {
            let time = event["time"].dateValue
            guard time != nil else {
                XCTFail("`time` is not a `Date` or doesn't exist.")
                return
            }

            print("Event: \(event)")
        }
    }

    func testInsertData() throws {
        let conn = try r.connect(host: BaseTests.host)
        let doc: Document = ["filename": "not_a_virus.exe", "data": Data(bytes: [1, 2, 4, 5, 3, 7, 29, 49, 59, 10, 53, 49, 59, 47, 94, 85, 74, 19, 4, 5, 6])]
        let result: WriteResult = try r.db("test").table("files").insert(doc).run(conn)

        XCTAssert(result.generatedKeys.count == 1, "Expected generatedKeys to contain 1, found \(result.generatedKeys.count)")
    }

    func testQueryData() throws {
        let conn = try r.connect(host: BaseTests.host)
        let files: Cursor<Document> = try r.db("test").table("files").run(conn)

        for file in files {
            guard file["data"].dataValue != nil else {
                XCTFail("`data` is not a `Data` or doesn't exist.")
                return
            }

            print("File: \(file)")
        }
    }

    static var allTests : [(String, (PseudoTypesTests) -> () throws -> Void)] {
        return [
            ("testInsertDate", testInsertDate),
            ("testQueryDate", testQueryDate),
            ("testInsertData", testInsertData),
            ("testQueryData", testQueryData)
        ]
    }
}
