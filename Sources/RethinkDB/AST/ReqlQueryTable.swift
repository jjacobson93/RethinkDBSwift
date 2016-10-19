//
//  ReqlQueryTable.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public protocol ReqlQueryTable: ReqlQuerySequence {}

extension ReqlQueryTable {
    public func insert(_ document: Document, options: InsertArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.insert.rawValue, [self.json, document.json], OptArgs(options).json])
    }
    
    /** Insert documents into a table. */
    public func insert(_ documents: [Document], options: InsertArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.insert.rawValue, [self.json, [ReqlTerm.makeArray.rawValue, documents.map { $0.json }]], OptArgs(options).json])
    }
    
    public func insert(_ object: ReqlSerializable, options: InsertArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.insert.rawValue, [self.json, object.json], OptArgs(options).json])
    }
    
    /** Insert documents into a table. */
    public func insert(_ objects: [ReqlSerializable], options: InsertArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.insert.rawValue, [self.json, [ReqlTerm.makeArray.rawValue, objects.map { return $0.json }]], OptArgs(options).json])
    }
    
    /** Update JSON documents in a table. Accepts a JSON document, a ReqlSerializable expression, or a combination of the two. */
    public func update(_ changes: Document, options: UpdateArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.update.rawValue, [self.json, changes], OptArgs(options).json])
    }
    
    public func update(_ changes: ReqlModification, options: UpdateArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.update.rawValue, [self.json, ReqlQueryLambda(changes).json], OptArgs(options).json])
    }
    
    /** Replace documents in a table. Accepts a JSON document or a ReqlSerializable expression, and replaces the original document with
     the new one. The new document must have the same primary key as Reqlthe original ocument.
     
     The replace command can be used to both insert and delete documents. If the “replaced” document has a primary key that
     doesn’t exist in the table, the document will be inserted; if an existing document is replaced with null, the document
     will be deleted. Since update and replace operations are performed atomically, this allows atomic inserts and deletes
     as well. */
    public func replace(_ changes: Document, options: UpdateArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.replace.rawValue, [self.json, changes], OptArgs(options).json])
    }
    
    public func replace(_ changes: ReqlPredicate, options: UpdateArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.replace.rawValue, [self.json, ReqlQueryLambda(changes).json], OptArgs(options).json])
    }
    
    /** Create a new secondary index on a table. Secondary indexes improve the speed of many read queries at the slight
     cost of increased storage space and decreased write performance.
     
     The indexFunction can be an anonymous function or a binary representation obtained from the function field of
     indexStatus. If successful, createIndex will return an object of the form {"created": 1}. */
    public func indexCreate(_ indexName: String, indexFunction: ReqlQueryLambda? = nil, options: IndexCreateArg...) -> ReqlQuery {
        if let fn = indexFunction {
            return ReqlExpr(json: [ReqlTerm.indexCreate.rawValue, [self.json, indexName, fn.json], OptArgs(options).json])
        }
        return ReqlExpr(json: [ReqlTerm.indexCreate.rawValue, [self.json, indexName], OptArgs(options).json])
    }
    
    public func indexWait() -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.indexWait.rawValue, [self.json]])
    }
    
    public func indexDrop(_ name: String) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.indexDrop.rawValue, [self.json, name]])
    }
    
    public func indexList() -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.indexList.rawValue, [self.json]])
    }
    
    /** Rename an existing secondary index on a table.  */
    public func indexRename(_ renameIndex: String, to: String, options: IndexRenameArg...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.indexRename.rawValue, [self.json, renameIndex, to], OptArgs(options).json])
    }
    
    /** Get the status of the specified indexes on this table, or the status of all indexes on this table if no indexes
     are specified. */
    public func indexStatus(_ indices: String...) -> ReqlQuery {
        var params: [Any] = [self.json]
        indices.forEach { params.append($0) }
        return ReqlExpr(json: [ReqlTerm.indexStatus.rawValue, params])
    }
    
    public func status() -> ReqlQuerySelection {
        return ReqlExpr(json: [ReqlTerm.status.rawValue, [self.json]])
    }
    
    public func sync() -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.sync.rawValue, [self.json]])
    }
    
    public func wait() -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.wait.rawValue, [self.json]])
    }
    
    public func get(_ primaryKey: Any) -> ReqlQueryRow {
        return ReqlQueryRow(json: [ReqlTerm.get.rawValue, [self.json, primaryKey]])
    }
    
    public func getAll(_ key: ReqlSerializable, index: String = "id") -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.getAll.rawValue, [self.json, key.json], ["index": index]])
    }
    
    public func rebalance() -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.rebalance.rawValue, [self.json]])
    }
    
    public func getAll(_ keys: [ReqlSerializable], index: String = "id") -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.getAll.rawValue, [self.json] + keys.map({$0.json}), ["index": index]])
    }
    
    public func orderBy(index: ReqlSerializable) -> ReqlQuerySequence {
        var querySequence: [Any] = [ReqlTerm.orderBy.rawValue, [self.json]]
        querySequence.append(["index": index.json])
        return ReqlExpr(json: querySequence)
    }
    
    public func between(_ lower: ReqlSerializable, _ upper: ReqlSerializable) -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.between.rawValue, [self.json, lower.json, upper.json]])
    }
    
    public func distinct() -> ReqlQueryStream {
        return ReqlExpr(json: [ReqlTerm.distinct.rawValue, [self.json]])
    }
    
    public func grant(_ userName: String, permissions: Permission...) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.grant.rawValue, [self.json, userName], OptArgs(permissions)])
    }
    
    public func getIntersecting(_ geometry: ReqlQueryGeometry, options: IntersectingArg...) -> ReqlQuerySelection {
        return ReqlExpr(json: [ReqlTerm.getIntersecting.rawValue, [self.json, geometry.json], OptArgs(options).json])
    }
}
