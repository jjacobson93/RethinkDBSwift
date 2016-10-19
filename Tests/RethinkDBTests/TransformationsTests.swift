//
//  TransformationsTests.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/19/16.
//
//

import Foundation

import XCTest
@testable import RethinkDB

class TransformationTests: BaseTests {

    func testMap() throws {
        let conn = try r.connect(host: BaseTests.host)
        let arr = [1, 2, 3]
        let expected = [2, 4, 6]
        
        let result: [Int] = try r.expr(arr).map({ (expr) -> (ReqlQuery) in
            return expr * 2
        }).run(conn)
        
        XCTAssertEqual(result, expected, "Expected \(expected), found \(result)")
    }
    
    static var allTests : [(String, (TransformationTests) -> () throws -> Void)] {
        return [
            ("testMap", testMap)
        ]
    }
}
