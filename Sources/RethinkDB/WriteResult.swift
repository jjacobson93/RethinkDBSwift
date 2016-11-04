//
//  WriteResult.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public struct WriteResult: __DocumentProtocolForArrayAdditions {
    private var document: Document
    
    public init(element: Any) {
        self.document = Document(element: element)
    }
    
    init(document: Document) {
        self.document = document
    }

    public var deleted: Int {
        return self.document["deleted"].int
    }
    
    public var errors: Int {
        return self.document["errors"].int
    }
    
    public var inserted: Int {
        return self.document["inserted"].int
    }
    
    public var replaced: Int {
        return self.document["replaced"].int
    }
    
    public var skipped: Int {
        return self.document["skipped"].int
    }
    
    public var unchanged: Int {
        return self.document["unchanged"].int
    }
    
    public var generatedKeys: [String] {
        return self.document["generated_keys"].array.map({ $0.string })
    }
    
    public var changes: [ChangesDocument] {
        return self.document["changes"].array.map {
            ChangesDocument(document: $0.document)
        }
    }
}
