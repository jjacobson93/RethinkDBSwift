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
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3]
        let expected: [Int64] = [2, 4, 6]
        
        let result: [Int64] = try r.expr(arr).map({ expr -> (ReqlExpr) in
            return expr * 2
        }).run(conn)
        
        XCTAssertEqual(result, expected, "Expected \(expected), found \(result)")
    }
    
    func testWithFields() throws {
        let conn = try r.connect(host: Tests.host)
        let locations: Cursor<Document> = try r.table("locations").withFields("lat").run(conn)
        for location in locations {
            XCTAssert(location["lat"].hasValue, "Expected value, found nothing")
            XCTAssert(location["long"].isNothing, "Expected nothing, found: \(location["long"])")
        }
    }
    
    func testConcatMap() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3]
        let expected: [Int64] = [1, 2, 2, 4, 3, 6]
        let result: [Int64] = try r.expr(arr).concatMap({ x in [x, x.mul(2)] }).run(conn)
        
        XCTAssertEqual(result, expected, "Expected \(expected), found \(result)")
    }
    
    func testOrderBy() throws {
        let conn = try r.connect(host: Tests.host)
        
        let documents: [Document] = try r.db("galaxy").table("systems").orderBy(sortKey: "name").run(conn)
        var prev: Document?
        for system in documents {
            if let prev = prev {
                guard let systemName = system["name"].stringValue else {
                    XCTFail("Expected system[\"name\"] to be a string, found \(system["name"])")
                    return
                }
                
                XCTAssert(prev["name"].string <= systemName, "Expected \"\(prev["name"].string)\" <= \"\(systemName)\"")
            }
            
            prev = system
        }
    }
    
    func testSkip() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected: [Int64] = [6, 7, 8, 9, 10]
        let result: [Int64] = try r.expr(arr).skip(5).run(conn)
        
        XCTAssertEqual(result, expected, "Expected \(expected), found \(result)")
    }
    
    func testLimit() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected: [Int64] = [1, 2, 3, 4, 5]
        let result: [Int64] = try r.expr(arr).limit(5).run(conn)
        
        XCTAssertEqual(result, expected, "Expected \(expected), found \(result)")
    }
    
    func testSliceFunction() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected1: [Int64] = [1, 2, 3, 4, 5]
        let expected2: [Int64] = [1, 2, 3, 4]
        let expected3: [Int64] = [3, 4, 5, 6, 7]
        
        let slice1: [Int64] = try r.expr(arr).slice(0, 5).run(conn)
        XCTAssertEqual(slice1, expected1, "Expected \(expected1), found \(slice1)")
        
        let slice2: [Int64] = try r.expr(arr).slice(0, 3, rightBound: .closed).run(conn)
        XCTAssertEqual(slice2, expected2, "Expected \(expected2), found \(slice2)")
        
        let slice3: [Int64] = try r.expr(arr).slice(2, 7).run(conn)
        XCTAssertEqual(slice3, expected3, "Expected \(expected3), found \(slice3)")
    }
    
    func testSliceSubscript() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected1: [Int64] = [1, 2, 3, 4, 5]
        let expected2: [Int64] = [1, 2, 3, 4]
        let expected3: [Int64] = [3, 4, 5, 6, 7]
        
        let slice1: [Int64] = try r.expr(arr)[0..<5].run(conn)
        XCTAssertEqual(slice1, expected1, "Expected \(expected1), found \(slice1)")
        
        let slice2: [Int64] = try r.expr(arr)[0...3].run(conn)
        XCTAssertEqual(slice2, expected2, "Expected \(expected2), found \(slice2)")
        
        let slice3: [Int64] = try r.expr(arr)[2..<7].run(conn)
        XCTAssertEqual(slice3, expected3, "Expected \(expected3), found \(slice3)")
    }
    
    func testNthFunction() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3]
        let expected: Int64 = 2
        let result: Int64 = try r.expr(arr).nth(1).run(conn)
        
        XCTAssertEqual(result, expected, "Expected \(expected), found \(result)")
    }
    
    func testNthSubscript() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3]
        let expected: Int64 = 2
        let result: Int64 = try r.expr(arr)[1].run(conn)
        
        XCTAssertEqual(result, expected, "Expected \(expected), found \(result)")
    }
    
    func testOffsetsOf() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = ["a", "b", "c"]
        let expected: [Int64] = [2]
        let result: [Int64] = try r.expr(arr).offsetsOf("c").run(conn)
        
        XCTAssertEqual(result, expected, "Expected \(expected), found \(result)")
    }
    
    func testIsEmpty() throws {
        let conn = try r.connect(host: Tests.host)
        let result1: Bool = try r.expr([1, 2, 3]).isEmpty().run(conn)
        XCTAssertEqual(result1, false, "Expected false, found \(result1)")
        
        let result2: Bool = try r.expr([]).isEmpty().run(conn)
        XCTAssertEqual(result2, true, "Expected true, found \(result2)")
    }
    
    func testUnion() throws {
        let conn = try r.connect(host: Tests.host)
        let expected: [Int64] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        let result: [Int64] = try r.expr([1, 2]).union([3, 4], [5, 6], [7, 8, 9]).run(conn)
        XCTAssertEqual(result, expected, "Expected \(expected), found \(result)")
    }
    
    func testSample() throws {
        let conn = try r.connect(host: Tests.host)
        let arr = [1, 2, 3, 4, 5]
        let count = 2
        let result: [Int64] = try r.expr(arr).sample(count).run(conn)
        XCTAssertEqual(result.count, count, "Expected \(count), found \(result.count)")
    }
    
    static var allTests : [(String, (TransformationTests) -> () throws -> Void)] {
        return [
            ("testMap", testMap),
            ("testWithFields", testWithFields),
            ("testConcatMap", testConcatMap),
            ("testOrderBy", testOrderBy),
            ("testSkip", testSkip),
            ("testLimit", testLimit),
            ("testSliceFunction", testSliceFunction),
            ("testSliceSubscript", testSliceSubscript),
            ("testNthFunction", testNthFunction),
            ("testNthSubscript", testNthSubscript),
            ("testOffsetsOf", testOffsetsOf),
            ("testIsEmpty", testIsEmpty),
            ("testUnion", testUnion),
            ("testSample", testSample)
        ]
    }
}
