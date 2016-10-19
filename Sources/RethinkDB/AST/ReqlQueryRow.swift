//
//  ReqlQueryRow.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public class ReqlQueryRow: ReqlExpr {
    
    public func update(_ changes: Document, options: UpdateArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.update.rawValue, [self.json, changes.json], OptArgs(options).json])
    }
    
    public func delete(_ options: DeleteArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.delete.rawValue, [self.json], OptArgs(options).json])
    }
    
    public func keys() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.keys.rawValue, [self.json]])
    }
}
