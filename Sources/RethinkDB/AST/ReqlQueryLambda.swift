//
//  ReqlQueryLambda.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public typealias ReqlModification = (ReqlSerializable) -> ([String: ReqlQuery])

public typealias ReqlPredicate = (ReqlExpr) -> (ReqlQuery)

public class ReqlQueryLambda: ReqlQuery {
    public let json: Any
    private static var parameterCounter = 0
    
    init(_ block: ReqlPredicate) {
        ReqlQueryLambda.parameterCounter += 1
        let p = ReqlQueryLambda.parameterCounter
        let parameter = ReqlExpr(json: p)
        let parameterAccess = ReqlExpr(json: [ReqlTerm.var.rawValue, [parameter.json]])
        
        self.json = [
            ReqlTerm.func.rawValue, [
                [ReqlTerm.makeArray.rawValue, [parameter.json]],
                block(parameterAccess).json
            ]
        ]
    }
    
    init(_ block: ReqlModification) {
        ReqlQueryLambda.parameterCounter += 1
        let p = ReqlQueryLambda.parameterCounter
        let parameter = ReqlExpr(json: p)
        let parameterAccess = ReqlExpr(json: [ReqlTerm.var.rawValue, [parameter.json]])
        
        let changes = block(parameterAccess)
        var serializedChanges: [String: Any] = [:]
        for (k, v) in changes {
            serializedChanges[k] = v.json
        }
        
        self.json = [
            ReqlTerm.func.rawValue, [
                [ReqlTerm.makeArray.rawValue, [parameter.json]],
                serializedChanges
            ]
        ]
    }
}
