//
//  ChangesDocument.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public class ChangesDocument: Document {
    public var newValue: Document {
        return self["new_val"].document
    }
    
    public var oldValue: Document {
        return self["old_val"].document
    }
}
