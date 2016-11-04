//
//  ReqlQueryLambda.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation
import Dispatch

public typealias ReqlModification = (ReqlSerializable) -> [String: ReqlQuery]
public typealias ReqlPredicate1 = (ReqlExpr) -> ReqlExpr
public typealias ReqlPredicate2 = (ReqlExpr, ReqlExpr) -> ReqlExpr
public typealias ReqlPredicate = ReqlPredicate1

public class ReqlQueryLambda: ReqlQuery {
    public let json: Any
    private static var parameterLock = DispatchQueue(label: "io.jjacobson.RethinkDBSwift")
    private static var parameterCounter = 0
    
    init(_ block: ReqlPredicate1) {
        let parameter = ReqlExpr(json: ReqlQueryLambda.nextParameter())
        let parameterAccess = ReqlExpr(json: [ReqlTerm.var.rawValue, [parameter.json]])
        
        self.json = [
            ReqlTerm.func.rawValue, [
                [ReqlTerm.makeArray.rawValue, [parameter.json]],
                block(parameterAccess).json
            ]
        ]
    }
    
    init(_ block: ReqlPredicate2) {
        let parameter1 = ReqlExpr(json: ReqlQueryLambda.nextParameter())
        let parameter2 = ReqlExpr(json: ReqlQueryLambda.nextParameter())
        let parameterAccess1 = ReqlExpr(json: [ReqlTerm.var.rawValue, [parameter1.json]])
        let parameterAccess2 = ReqlExpr(json: [ReqlTerm.var.rawValue, [parameter2.json]])

        self.json = [
            ReqlTerm.func.rawValue, [
                [ReqlTerm.makeArray.rawValue, [parameter1.json, parameter2.json]],
                block(parameterAccess1, parameterAccess2).json
            ]
        ]
    }
    
    init(_ block: ReqlModification) {
        let p = ReqlQueryLambda.nextParameter()
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
    
    private static func nextParameter() -> Int {
        self.parameterLock.sync {
            self.parameterCounter += 1
        }
        return self.parameterCounter
    }
}
