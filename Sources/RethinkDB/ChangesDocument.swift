//
//  ChangesDocument.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public class ChangesDocument {
    private var document: Document
    
    init(document: Document) {
        self.document = document
    }
    
    public var newValue: Document {
        return self.document["new_val"].document
    }
    
    public var oldValue: Document {
        return self.document["old_val"].document
    }
}
