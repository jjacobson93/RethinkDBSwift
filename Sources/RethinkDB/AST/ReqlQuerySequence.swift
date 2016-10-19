//
//  ReqlQuerySequence.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public protocol ReqlQuerySequence: ReqlQuery {}
extension ReqlQuerySequence {
    public func distinct() -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.distinct.rawValue, [self.json]])
    }
    
    public func count() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.count.rawValue, [self.json]])
    }
    
    public func limit(_ count: Int) -> ReqlQueryStream {
        return ReqlExpr(json: [ReqlTerm.limit.rawValue, [self.json, count]])
    }
    
    public func skip(_ count: Int) -> ReqlQueryStream {
        return ReqlExpr(json: [ReqlTerm.skip.rawValue, [self.json, count]])
    }
    
    public func sample(_ count: Int) -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.sample.rawValue, [self.json, count]])
    }
    
    public func slice(_ startOffset: Int, _ endOffset: Int, leftBound: RangeInclusion = .closed, rightBound: RangeInclusion = .open) -> ReqlQuerySequence {
        let options = OptArgs<SliceArg>([.leftBound(leftBound), .rightBound(rightBound)])
        return ReqlExpr(json: [ReqlTerm.slice.rawValue, [self.json, startOffset, endOffset], options.json])
    }
    
    public func slice(_ range: Range<Int>) -> ReqlQuerySequence {
        return self.slice(range.lowerBound, range.upperBound)
    }
    
    public func slice(_ range: ClosedRange<Int>) -> ReqlQuerySequence {
        return self.slice(range.lowerBound, range.upperBound, rightBound: .closed)
    }
    
    public func nth(_ index: Int) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.nth.rawValue, [self.json, index]])
    }
    
    public func offsetsOf(_ element: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.offsetsOf.rawValue, [self.json, element.json]])
    }
    
    public func offsetsOf(_ predicate: ReqlPredicate) -> ReqlExpr {
        let fun = ReqlQueryLambda(predicate)
        return ReqlExpr(json: [ReqlTerm.offsetsOf.rawValue, [self.json, fun.json]])
    }
    
    public func isEmpty() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.isEmpty.rawValue, [self.json]])
    }
    
    public func filter(_ specification: [String: ReqlSerializable], options: FilterArg...) -> ReqlQuerySequence {
        var serialized: [String: Any] = [:]
        for (k, v) in specification {
            serialized[k] = v.json
        }
        return ReqlExpr(json: [ReqlTerm.filter.rawValue, [self.json, serialized], OptArgs(options).json])
    }
    
    public func filter(_ predicate: ReqlPredicate) -> ReqlQuerySequence {
        let fun = ReqlQueryLambda(predicate)
        return ReqlExpr(json: [ReqlTerm.filter.rawValue, [self.json, fun.json]])
    }
    
    public func forEach(_ block: ReqlPredicate) -> ReqlQuerySequence {
        let fun = ReqlQueryLambda(block)
        return ReqlExpr(json: [ReqlTerm.forEach.rawValue, [self.json, fun.json]])
    }
    
    public func innerJoin(_ foreign: ReqlQuerySequence, predicate: ReqlPredicate) -> ReqlQueryStream {
        return ReqlExpr(json: [ReqlTerm.innerJoin.rawValue, [self.json, foreign.json, ReqlQueryLambda(predicate).json]])
    }
    
    public func outerJoin(_ foreign: ReqlQuerySequence, predicate: ReqlPredicate) -> ReqlQueryStream {
        return ReqlExpr(json: [ReqlTerm.outerJoin.rawValue, [self.json, foreign.json, ReqlQueryLambda(predicate).json]])
    }
    
    public func eqJoin(_ leftField: ReqlSerializable, foreign: ReqlQueryTable, options: EqJoinArg...) -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.eqJoin.rawValue, [self.json, leftField.json, foreign.json], OptArgs(options).json])
    }
    
    public func map(_ mapper: ReqlQueryLambda) -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.map.rawValue, [self.json, mapper.json]])
    }
    
    public func map(_ block: ReqlPredicate) -> ReqlQuerySequence {
        return self.map(ReqlQueryLambda(block))
    }
    
    public func concatMap(_ predicate: ReqlPredicate) -> ReqlQuerySequence {
        let fun = ReqlQueryLambda(predicate)
        return ReqlExpr(json: [ReqlTerm.concatMap.rawValue, [self.json, fun.json]])
    }
    
    public func withFields(_ fields: [ReqlSerializable]) -> ReqlQuerySequence {
        let values = fields.map({ e in return e.json })
        return ReqlExpr(json: [ReqlTerm.withFields.rawValue, [self.json, [ReqlTerm.makeArray.rawValue, values]]])
    }
    
    public func union(_ sequence: ReqlQuerySequence) -> ReqlQueryStream {
        return ReqlExpr(json: [ReqlTerm.union.rawValue, [self.json, sequence.json]])
    }
    
    public func delete(_ options: DeleteArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.delete.rawValue, [self.json], OptArgs(options).json])
    }
    
    public func changes(_ options: ChangesArg...) -> ReqlQueryStream {
        return ReqlExpr(json: [ReqlTerm.changes.rawValue, [self.json], OptArgs(options).json])
    }
    
    /** In its first form, fold operates like reduce, returning a value by applying a combining function to each element
     in a sequence, passing the current element and the previous reduction result to the function. However, fold has the
     following differences from reduce:
     - it is guaranteed to proceed through the sequence from first element to last.
     - it passes an initial base value to the function with the first element in place of the previous reduction result. */
    public func fold(_ base: ReqlSerializable, accumulator: ReqlQueryLambda, options: FoldArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.fold.rawValue, [self.json, base.json, accumulator.json], OptArgs(options).json])
    }
    
    public func without(fields: [ReqlSerializable]) -> ReqlQuerySequence {
        let values = fields.map({ e in return e.json })
        return ReqlExpr(json: [ReqlTerm.without.rawValue, [self.json, [ReqlTerm.makeArray.rawValue, values]]])
    }
    
    public func orderBy(sortKey: ReqlSerializable) -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.orderBy.rawValue, [self.json, sortKey.json]])
    }
    
    public func has(field: ReqlSerializable) -> ReqlQuerySequence {
        return self.has(fields: [field])
    }
    
    public func has(fields: [ReqlSerializable]) -> ReqlQuerySequence {
        let values = fields.map({ e in return e.json})
        return ReqlExpr(json: [ReqlTerm.hasFields.rawValue, [self.json, [ReqlTerm.makeArray.rawValue, values]]])
    }
    
    public func zip() -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.zip.rawValue, [self.json]])
    }
    
    /** Subscripts **/
    
    public subscript(_ index: Int) -> ReqlExpr {
        return self.nth(index)
    }
    
    public subscript(_ range: Range<Int>) -> ReqlQuerySequence {
        return self.slice(range)
    }
    
    public subscript(_ closedRange: ClosedRange<Int>) -> ReqlQuerySequence {
        return self.slice(closedRange)
    }
}

public protocol ReqlQuerySelection: ReqlQuerySequence {}
public protocol ReqlQueryStream: ReqlQuerySequence {}

extension ReqlQueryStream {
    public func concatMap(_ predicate: ReqlPredicate) -> ReqlQueryStream {
        let fun = ReqlQueryLambda(predicate)
        return ReqlExpr(json: [ReqlTerm.concatMap.rawValue, [self.json, fun.json]])
    }
    
    public func zip() -> ReqlQueryStream {
        return ReqlExpr(json: [ReqlTerm.zip.rawValue, [self.json]])
    }
    
    public func sample(_ count: Int) -> ReqlQueryStream {
        return ReqlExpr(json: [ReqlTerm.sample.rawValue, [self.json, count]])
    }
}
