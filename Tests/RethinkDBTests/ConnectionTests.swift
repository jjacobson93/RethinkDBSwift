import XCTest
@testable import RethinkDB

class ConnectionTests: BaseTests {
    func testConnectionV0_4() throws {
        let conn = try r.connect(host: Tests.host, protocolVersion: .v0_4)
        conn.close()
    }

    func testConnectionV1_0() throws {
        let conn = try r.connect(host: Tests.host) // .v1_0 by default
        conn.close()
    }
    
    func testUse() throws {
        let conn = try r.connect(host: Tests.host)
        conn.use("galaxy")
        
        let _: Cursor<Document> = try r.table("systems").run(conn)
    }
    
    func testServerInfo() throws {
        let conn = try r.connect(host: Tests.host)
        let info = try conn.server()
        print("Server info: \(info)")
    }

    static var allTests : [(String, (ConnectionTests) -> () throws -> Void)] {
        return [
            ("testConnectionV0_4", testConnectionV0_4),
            ("testConnectionV1_0", testConnectionV1_0),
            ("testUse", testUse),
            ("testServerInfo", testServerInfo)
        ]
    }
}
