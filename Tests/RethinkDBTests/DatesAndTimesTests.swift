//
//  DatesAndTimesTests.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation
import XCTest
@testable import RethinkDB

class DatesAndTimesTests: BaseTests {
    var conn: Connection!
    
    override func setUp() {
        super.setUp()
        self.conn = try! r.connect(host: Tests.host)
    }
    
    func testNow() throws {
        let object = r.object(
            "title", "Dinner: meatloaf",
            "time", r.now()
        )
        
        let _: Document = try r.db("test").table("calendar").insert(object).run(conn)
    }
    
    func testTime() throws {
        let result: WriteResult = try r.db("test").table("contacts").insert(
            r.object(
                "name", "John",
                "birthdate", r.time(year: 1989, month: 3, day: 8, timezone: "Z")
            )
        ).run(conn)
        
        XCTAssert(result.generatedKeys.count == 1)
    }
    
    func testEpochTime() throws {
        let result: WriteResult = try r.db("test").table("contacts").insert(
            r.object(
                "name", "John",
                "birthdate", r.epochTime(10000000)
            )
        ).run(conn)
        
        XCTAssert(result.generatedKeys.count == 1)
    }
    
    func testInTimezone() throws {
        let t: Date = try r.now().inTimezone("-08:00").run(conn)
        
        print("In timezone: \(t)")
    }
    
    func testTimezone() throws {
        let _: Cursor<Document> = try r.db("test").table("contacts").filter({ user in
            return user["birthdate"].timezone() == "-07:00"
        }).run(conn)
    }
    
    func testYear() throws {
        let year: Int64 = try r.time(year: 2016, month: 8, day: 10, timezone: "Z").year().run(conn)
        
        XCTAssert(year == 2016, "Expected year to equal 2016, found \(year)")
    }
    
    func testMonth() throws {
        let month: Int64 = try r.time(year: 2016, month: 8, day: 10, timezone: "Z").month().run(conn)
        
        XCTAssert(month == 8, "Expected month to equal 8, found \(month)")
    }
    
    func testDay() throws {
        let day: Int64 = try r.time(year: 2016, month: 8, day: 10, timezone: "Z").day().run(conn)
        
        XCTAssert(day == 10, "Expected day to equal 10, found \(day)")
    }
    
    func testHours() throws {
        let hours: Int64 = try r.time(year: 2016, month: 8, day: 10, hour: 18, timezone: "Z").hours().run(conn)
        
        XCTAssert(hours == 18, "Expected hours to equal 18, found \(hours)")
    }
    
    func testMinutes() throws {
        let minutes: Int64 = try r.time(year: 2016, month: 8, day: 10, hour: 18, minute: 33, timezone: "Z").minutes().run(conn)
        
        XCTAssert(minutes == 33, "Expected hours to equal 33, found \(minutes)")
    }
    
    func testSeconds() throws {
        let seconds: Int64 = try r.time(year: 2016, month: 8, day: 10, hour: 18, minute: 33, second: 59, timezone: "Z").seconds().run(conn)
        
        XCTAssert(seconds == 59, "Expected seconds to equal 59, found \(seconds)")
    }
    
    static var allTests : [(String, (DatesAndTimesTests) -> () throws -> Void)] {
        return [
            ("testNow", testNow),
            ("testTime", testTime),
            ("testEpochTime", testEpochTime),
            ("testInTimezone", testInTimezone),
            ("testTimezone", testTimezone),
            ("testYear", testYear),
            ("testMonth", testMonth),
            ("testDay", testDay),
            ("testHours", testHours),
            ("testMinutes", testMinutes),
            ("testSeconds", testSeconds)
        ]
    }
}
