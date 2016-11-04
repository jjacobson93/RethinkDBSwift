//
//  AggregationTests.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/20/16.
//
//

import Foundation

import XCTest
@testable import RethinkDB

class AggregationTests: BaseTests {
    
    func testContainsValue() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3, 4, 5]
        let result1: Bool = try r.expr(arr).contains(2, 3).run(conn)
        XCTAssertTrue(result1, "Expected \(arr) to contain 2 and 3")
        
        let result2: Bool = try r.expr(arr).contains(2, 10).run(conn)
        XCTAssertFalse(result2, "Expected \(arr) not to contain 10")
    }
    
    func testContainsFunction() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3, 4, 5]
        do {
            let result1: Bool = try r.expr(arr).contains(
                { v in return v == 2 },
                { v in return v == 3 }
                ).run(conn)
            
            XCTAssertTrue(result1, "Expected \(arr) to contain 2 and 3")
        } catch let error as ReqlError {
            print(error.localizedDescription)
            throw error
        }
    }
    
    static var allTests: [(String, (AggregationTests) -> () throws -> Void)] = [
        ("testContainsValue", testContainsValue),
        ("testContainsFunction", testContainsFunction)
    ]
}
