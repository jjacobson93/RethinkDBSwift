//
//  ExprTests.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 11/18/16.
//
//

import Foundation

import XCTest
@testable import RethinkDB

class ExprTests: BaseTests {
    func testArray() throws {
        let arr: [Int64] = [1, 2, 3, 4, 5]
        let result: [Int64] = try r.expr(arr).run(conn)
        XCTAssertEqual(result, arr, "Expected \(arr), found \(result)")
    }
    
    static var allTests: [(String, (ExprTests) -> () throws -> Void)] = [
        ("testArray", testArray)
    ]
}
