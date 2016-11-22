//
//  ReqlType.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 11/21/16.
//
//

import Foundation

public enum ReqlType: String {
    case time = "TIME"
    case geometry = "GEOMETRY"
    case binary = "BINARY"
    
    public static let key = "$reql_type$"
}
