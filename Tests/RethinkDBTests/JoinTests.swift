//
//  JoinTests.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/20/16.
//
//

import Foundation

import XCTest
@testable import RethinkDB

class JoinTests: BaseTests {

    func testInnerJoin() throws {
        let conn = try r.connect(host: Tests.host)
        
        let owners: [Document] = [
            [ "name": "John", "pets": ["Fido"] ],
            [ "name": "Bill", "pets": ["Cheep", "Zipper", "Nolan"] ]
        ]
        
        let pets: [Document] = [
            [ "name": "Fido", "age": 10, "species": "Dog" ], [ "name": "Cheep", "age": 3, "species": "Bird" ],
            [ "name": "Zipper", "age": 4, "species": "Cat" ], [ "name": "Nolan", "age": 8, "species": "Hamster" ]
        ]

        let results: [Document] = try r.expr(owners).innerJoin(r.expr(pets), predicate: { (owner, pet) -> (ReqlExpr) in
            return owner["pets"].contains(pet["name"])
        }).run(conn)
        
        for result in results {
            print("Result: \(result)")
        }
    }
    
    func testOuterJoin() throws {
        let conn = try r.connect(host: Tests.host)
        
        let owners: [Document] = [
            [ "name": "John", "pets": ["Fido"] ],
            [ "name": "Bill", "pets": ["Cheep", "Zipper", "Nolan"] ],
            [ "name": "Gregory", "pets": [] ]
        ]
        
        let pets: [Document] = [
            [ "name": "Fido", "age": 10, "species": "Dog" ], [ "name": "Cheep", "age": 3, "species": "Bird" ],
            [ "name": "Zipper", "age": 4, "species": "Cat" ], [ "name": "Nolan", "age": 8, "species": "Hamster" ]
        ]
        
        let results: [Document] = try r.expr(owners).outerJoin(r.expr(pets), predicate: { (owner, pet) -> (ReqlExpr) in
            return owner["pets"].contains(pet["name"])
        }).run(conn)
        
        for result in results {
            print("Result: \(result)")
        }
    }
    
    func testEqJoin() throws {
        let conn = try r.connect(host: Tests.host)
        
        let results: Cursor<Document> = try r.db("galaxy").table("systems")
            .concatMap({ (row) -> ReqlExpr in
                return row["stars"].map({ (star) -> ReqlExpr in
                    return row.merge([ "stars": star ])
                })
            })
            .eqJoin("stars", foreign: r.db("galaxy").table("stars"), options: .index("name"))
            .run(conn)
        for result in results {
            print("Result: \(result)")
        }
    }
    
    func testZip() throws {
        let conn = try r.connect(host: Tests.host)
        
        let results: Cursor<Document> = try r.db("galaxy").table("systems")
            .concatMap({ (row) -> ReqlExpr in
                return row["stars"].map({ (star) -> ReqlExpr in
                    return row.merge([ "stars": star ])
                })
            })
            .eqJoin("stars", foreign: r.db("galaxy").table("stars"), options: .index("name"))
            .zip()
            .run(conn)
        
        for result in results {
            print("Result: \(result)")
        }
    }
    
    static var allTests: [(String, (JoinTests) -> () throws -> Void)] = [
        ("testInnerJoin", testInnerJoin),
        ("testOuterJoin", testOuterJoin),
        ("testEqJoin", testEqJoin)
    ]
}
