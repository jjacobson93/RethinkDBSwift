//
//  MathAndLogicTests.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/18/16.
//
//

import XCTest
@testable import RethinkDB

class MathAndLogicTests: BaseTests {
    
    func testAdd() throws {
        let conn = try r.connect(host: Tests.host)
        let result: Int = try (r.expr(2) + 2).run(conn)
        XCTAssert(result == 4, "Expected result to equal 4, found \(result)")
    }
    
    func testSubtract() throws {
        let conn = try r.connect(host: Tests.host)
        let result: Int = try (r.expr(4) - 2).run(conn)
        XCTAssert(result == 2, "Expected result to equal 2, found \(result)")
    }
    
    func testMultiply() throws {
        let conn = try r.connect(host: Tests.host)
        let result: Int = try (r.expr(2) * 2).run(conn)
        XCTAssert(result == 4, "Expected result to equal 4, found \(result)")
    }
    
    func testDivide() throws {
        let conn = try r.connect(host: Tests.host)
        let result: Int = try (r.expr(8) / 2).run(conn)
        XCTAssert(result == 4, "Expected result to equal 4, found \(result)")
    }
    
    func testMod() throws {
        let conn = try r.connect(host: Tests.host)
        let result: Int = try (r.expr(10) % 3).run(conn)
        XCTAssert(result == 1, "Expected result to equal 1, found \(result)")
    }
    
    func testAnd() throws {
        let conn = try r.connect(host: Tests.host)
        let result: Bool = try (r.expr(true) && false).run(conn)
        XCTAssert(!result, "Expected result to equal false, found \(result)")
    }
    
    func testOr() throws {
        let conn = try r.connect(host: Tests.host)
        let result: Bool = try (r.expr(true) || false).run(conn)
        XCTAssert(result, "Expected result to equal true, found \(result)")
    }
    
    func testEqual() throws {
        let conn = try r.connect(host: Tests.host)
        let result: Bool = try (r.expr(2) == 2).run(conn)
        XCTAssert(result, "Expected result to equal true, found \(result)")
    }
    
    func testNotEqual() throws {
        let conn = try r.connect(host: Tests.host)
        let result: Bool = try (r.expr(3) != 3).run(conn)
        XCTAssert(!result, "Expected result to equal false, found \(result)")
    }
    
    static var allTests : [(String, (MathAndLogicTests) -> () throws -> Void)] {
        return [
            ("testAdd", testAdd),
            ("testSubtract", testSubtract),
            ("testMultiply", testMultiply),
            ("testDivide", testDivide),
            ("testMod", testMod),
            ("testAnd", testAnd),
            ("testOr", testOr),
            ("testEqual", testEqual),
            ("testNotEqual", testNotEqual)
        ]
    }
}
