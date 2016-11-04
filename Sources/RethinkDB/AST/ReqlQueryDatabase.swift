//
//  ReqlQueryDatabase.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public class ReqlQueryDatabase: ReqlQuery, ExpressibleByStringLiteral {
    public let json: Any
    
    internal init(name: String) {
        self.json = [ReqlTerm.db.rawValue, [name]]
    }
    
    public convenience required init(stringLiteral value: String) {
        self.init(name: value)
    }
    
    public convenience required init(unicodeScalarLiteral value: String) {
        self.init(name: value)
    }
    
    public convenience required init(extendedGraphemeClusterLiteral value: String) {
        self.init(name: value)
    }
    
    public func table(_ name: String, options: TableArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.table.rawValue, [self.json, name], OptArgs(options).json])
    }
    
    public func tableCreate(_ name: String, options: TableCreateArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.tableCreate.rawValue, [self.json, name], OptArgs(options).json])
    }
    
    public func tableDrop(_ name: String) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.tableDrop.rawValue, [self.json, name]])
    }
    
    public func tableList() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.tableList.rawValue, [self.json]])
    }
    
    public func wait() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.wait.rawValue, [self.json]])
    }
    
    public func rebalance() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.rebalance.rawValue, [self.json]])
    }
    
    public func grant(_ userName: String, permissions: Permission...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.grant.rawValue, [self.json, userName], OptArgs(permissions).json])
    }
}
