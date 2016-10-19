//
//  UpdateTests.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import XCTest
@testable import RethinkDB

class UpdateTests: BaseTests {
    
    var id: String!
    
    override func setUp() {
        super.setUp()
        
        do {
            let conn = try r.connect(host: BaseTests.host)
            let object = r.object([
                "title": "My awesome event",
                "time": r.now()
            ])
            
            guard let result: WriteResult = try r.table("calendar").insert(object).run(conn) else {
                fatalError("Cannot insert object")
            }
            
            print("Result: \(result)")
            self.id = result.generatedKeys[0]
        } catch let error {
            fatalError("Failure setting up UpdateTests: \(error)")
        }
    }
    
    func testUpdateOne() throws {
        let conn = try r.connect(host: BaseTests.host)
        let newTitle = "My super awesome event"
        let update: Document = [ "title": newTitle ]
        
        let result: WriteResult = try r.table("calendar").get(self.id).update(update, options: .returnChanges(true)).run(conn)
        
        let changes = result.changes[0]
        XCTAssertNotNil(changes.newValue)
        XCTAssert(changes.newValue.get("title") == newTitle)
    }
    
    static var allTests : [(String, (UpdateTests) -> () throws -> Void)] {
        return [
            ("testUpdateOne", testUpdateOne)
        ]
    }
}
