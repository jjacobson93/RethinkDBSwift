//
//  ReqlQuery.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public protocol ReqlQuery: ReqlSerializable {}

public extension ReqlQuery {
    @discardableResult
    public func run<T>(_ connection: Connection, options: GlobalArg...) throws -> T {
        return try connection.run(self.json as! [Any], options: OptArgs(options))
    }

    @discardableResult
    public func run<T: ExpressibleByNilLiteral>(_ connection: Connection, options: GlobalArg...) throws -> T {
        return try connection.run(self.json as! [Any], options: OptArgs(options))
    }
    
    /// Note: This is not the same as runNoReply(). We wait for a reponse from the server,
    /// but we discard the result
//    public func run(_ connection: Connection, options: GlobalArg...) throws {
//        let _: Any? = try connection.run(self.json, options: OptArgs(options))
//    }
    
    public func runNoReply(_ connection: Connection, options: GlobalArg...) throws {
        try connection.runNoReply(self.json as! [Any], options: OptArgs(options))
    }
    
    public func typeOf() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.typeOf.rawValue, [self.json]])
    }
    
    public func coerceTo(_ type: ReqlTypeName) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.coerceTo.rawValue, [self.json, type]])
    }
    
    public func coerceTo(_ type: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.coerceTo.rawValue, [self.json, type.json]])
    }
    
    public func info() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.info.rawValue, [self.json]])
    }
}
