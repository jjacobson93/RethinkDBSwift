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
    // MARK: Transformations
    
    public func limit(_ count: Int) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.limit.rawValue, [self.json, count]])
    }
    
    public func skip(_ count: Int) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.skip.rawValue, [self.json, count]])
    }
    
    public func sample(_ count: Int) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.sample.rawValue, [self.json, count]])
    }
    
    public func slice(_ startOffset: Int, _ endOffset: Int, leftBound: RangeInclusion = .closed, rightBound: RangeInclusion = .open) -> ReqlExpr {
        let options = OptArgs<SliceArg>([.leftBound(leftBound), .rightBound(rightBound)])
        return ReqlExpr(json: [ReqlTerm.slice.rawValue, [self.json, startOffset, endOffset], options.json])
    }
    
    public func slice(_ range: Range<Int>) -> ReqlExpr {
        return self.slice(range.lowerBound, range.upperBound)
    }
    
    public func slice(_ range: ClosedRange<Int>) -> ReqlExpr {
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
    
    public func filter(_ specification: [String: ReqlSerializable], options: FilterArg...) -> ReqlExpr {
        var serialized: [String: Any] = [:]
        for (k, v) in specification {
            serialized[k] = v.json
        }
        return ReqlExpr(json: [ReqlTerm.filter.rawValue, [self.json, serialized], OptArgs(options).json])
    }
    
    public func filter(_ predicate: ReqlPredicate) -> ReqlExpr {
        let fun = ReqlQueryLambda(predicate)
        return ReqlExpr(json: [ReqlTerm.filter.rawValue, [self.json, fun.json]])
    }
    
    public func forEach(_ block: ReqlPredicate) -> ReqlExpr {
        let fun = ReqlQueryLambda(block)
        return ReqlExpr(json: [ReqlTerm.forEach.rawValue, [self.json, fun.json]])
    }
    
    public func innerJoin(_ foreign: ReqlQuerySequence, predicate: ReqlPredicate2) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.innerJoin.rawValue, [self.json, foreign.json, ReqlQueryLambda(predicate).json]])
    }
    
    public func outerJoin(_ foreign: ReqlQuerySequence, predicate: ReqlPredicate2) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.outerJoin.rawValue, [self.json, foreign.json, ReqlQueryLambda(predicate).json]])
    }
    
    public func eqJoin(_ leftField: ReqlSerializable, foreign: ReqlQueryTable, options: EqJoinArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.eqJoin.rawValue, [self.json, leftField.json, foreign.json], OptArgs(options).json])
    }
    
    public func map(_ mapper: ReqlQueryLambda) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.map.rawValue, [self.json, mapper.json]])
    }
    
    public func map(_ block: ReqlPredicate) -> ReqlExpr {
        return self.map(ReqlQueryLambda(block))
    }
    
    public func concatMap(_ predicate: ReqlPredicate) -> ReqlExpr {
        let fun = ReqlQueryLambda(predicate)
        return ReqlExpr(json: [ReqlTerm.concatMap.rawValue, [self.json, fun.json]])
    }
    
    public func withFields(_ fields: ReqlSerializable...) -> ReqlExpr {
        let values = fields.map({ e in return e.json })
        return ReqlExpr(json: [ReqlTerm.withFields.rawValue, [self.json, [ReqlTerm.makeArray.rawValue, values]]])
    }
    
    public func union(_ sequences: ReqlExpr...) -> ReqlExpr {
        var arguments = [self.json]
        arguments.append(contentsOf: sequences.map({ $0.json }))
        return ReqlExpr(json: [ReqlTerm.union.rawValue, arguments])
    }
    
    public func delete(_ options: DeleteArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.delete.rawValue, [self.json], OptArgs(options).json])
    }
    
    public func changes(_ options: ChangesArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.changes.rawValue, [self.json], OptArgs(options).json])
    }
    
    /** In its first form, fold operates like reduce, returning a value by applying a combining function to each element
     in a sequence, passing the current element and the previous reduction result to the function. However, fold has the
     following differences from reduce:
     - it is guaranteed to proceed through the sequence from first element to last.
     - it passes an initial base value to the function with the first element in place of the previous reduction result. */
    public func fold(_ base: ReqlSerializable, accumulator: ReqlQueryLambda, options: FoldArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.fold.rawValue, [self.json, base.json, accumulator.json], OptArgs(options).json])
    }
    
    public func without(fields: [ReqlSerializable]) -> ReqlExpr {
        let values = fields.map({ e in return e.json })
        return ReqlExpr(json: [ReqlTerm.without.rawValue, [self.json, [ReqlTerm.makeArray.rawValue, values]]])
    }
    
    public func orderBy(_ sortKey: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.orderBy.rawValue, [self.json, sortKey.json]])
    }
    
    public func orderBy(_ sortKeys: ReqlSerializable..., index: String = "") -> ReqlExpr {
        var json: [Any] = [ReqlTerm.orderBy.rawValue]
        var params = [self.json]
        params.append(contentsOf: sortKeys.map { $0.json })
        json.append(params)
        if index != "" {
            json.append(["index": index.json])
        }
        return ReqlExpr(json: json)
    }
    
    public func orderBy(_ predicates: ReqlPredicate..., index: String = "") -> ReqlExpr {
        let lambdas = predicates.map({ ReqlQueryLambda($0) })
        var params = [self.json]
        params.append(contentsOf: lambdas.map { $0.json })
        if index != "" {
            params.append(["index": index.json])
        }
        return ReqlExpr(json: [ReqlTerm.orderBy.rawValue, params])
    }
    
    public func has(field: ReqlSerializable) -> ReqlExpr {
        return self.has(fields: [field])
    }
    
    public func has(fields: [ReqlSerializable]) -> ReqlExpr {
        let values = fields.map({ e in return e.json})
        return ReqlExpr(json: [ReqlTerm.hasFields.rawValue, [self.json, [ReqlTerm.makeArray.rawValue, values]]])
    }
    
    public func zip() -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.zip.rawValue, [self.json]])
    }
    
    // MARK: Aggregation
    
    public func group(_ fields: String...) -> ReqlExpr {
        let values = fields.map({ $0.json })
        return ReqlExpr(json: [ReqlTerm.group.rawValue, [self.json, values]])
    }
    
    public func group(_ predicates: ReqlPredicate...) -> ReqlExpr {
        let funcs = predicates.map({ ReqlQueryLambda($0).json })
        return ReqlExpr(json: [ReqlTerm.group.rawValue, [self.json, funcs]])
    }
    
    public func reduce(_ predicate: ReqlPredicate) -> ReqlExpr {
        let fn = ReqlQueryLambda(predicate)
        return ReqlExpr(json: [ReqlTerm.reduce.rawValue, [self.json, fn.json]])
    }
    
    public func count() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.count.rawValue, [self.json]])
    }
    
    public func distinct() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.distinct.rawValue, [self.json]])
    }
    
    public func contains(_ values: ReqlSerializable...) -> ReqlExpr {
        var args = [self.json]
        args.append(contentsOf: values.map({ $0.json }))
        return ReqlExpr(json: [ReqlTerm.contains.rawValue, args])
    }
    
    public func contains(_ predicates: ReqlPredicate...) -> ReqlExpr {
        var args = [self.json]
        args.append(contentsOf: predicates.map({ ReqlQueryLambda($0).json }))
        return ReqlExpr(json: [ReqlTerm.contains.rawValue, args])
    }
    
    // MARK: Subscripts
    
    public subscript(_ index: Int) -> ReqlExpr {
        return self.nth(index)
    }
    
    public subscript(_ range: Range<Int>) -> ReqlExpr {
        return self.slice(range)
    }
    
    public subscript(_ closedRange: ClosedRange<Int>) -> ReqlExpr {
        return self.slice(closedRange)
    }
}

public protocol ReqlQuerySelection: ReqlQuerySequence {}
public protocol ReqlQueryStream: ReqlQuerySequence {}

extension ReqlQueryStream {
    public func concatMap(_ predicate: ReqlPredicate) -> ReqlExpr {
        let fun = ReqlQueryLambda(predicate)
        return ReqlExpr(json: [ReqlTerm.concatMap.rawValue, [self.json, fun.json]])
    }
    
    public func zip() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.zip.rawValue, [self.json]])
    }
    
    public func sample(_ count: Int) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.sample.rawValue, [self.json, count]])
    }
}


public protocol ReqlQueryGroupedStream: ReqlQueryStream {}

extension ReqlQueryGroupedStream {
    public func ungroup() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.ungroup.rawValue, [self.json]])
    }
}
