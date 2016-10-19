//
//  WriteResult.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public class WriteResult: Document {
    public var deleted: Int {
        return self["deleted"].int
    }
    
    public var errors: Int {
        return self["errors"].int
    }
    
    public var inserted: Int {
        return self["inserted"].int
    }
    
    public var replaced: Int {
        return self["replaced"].int
    }
    
    public var skipped: Int {
        return self["skipped"].int
    }
    
    public var unchanged: Int {
        return self["unchanged"].int
    }
    
    public var generatedKeys: [String] {
        return self["generated_keys"].array.map({ $0.string })
    }
    
    public var changes: [ChangesDocument] {
        return self["changes"].array.map {
            ChangesDocument(document: $0.document)
        }
    }
}
