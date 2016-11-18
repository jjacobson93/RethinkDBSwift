//
//  Number.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 11/17/16.
//
//

import Foundation
import WarpCore

// because NSNumber sucks
public enum Number: ReqlSerializable, CustomStringConvertible, CustomDebugStringConvertible {
    case int(Int64)
    case uint(UInt64)
    case float(Float)
    case double(Double)

    public var description: String {
        switch self {
        case .int(let i): return i.description
        case .uint(let u): return u.description
        case .float(let f): return f.description
        case .double(let d): return d.description
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .int(let i): return i.description
        case .uint(let u): return u.description
        case .float(let f): return f.debugDescription
        case .double(let d): return d.debugDescription
        }
    }
    
    public var json: Any {
        switch self {
        case .int(let i): return i
        case .uint(let u): return u
        case .float(let f): return f
        case .double(let d): return d
        }
    }
}

extension Number: JSONConvertible {
    public init(json: JSON) throws {
        switch json {
        case .integer(let i):
            self = .int(i)
        default:
            throw JSON.Error.invalidNumber
        }
    }
    
    public func encoded() -> JSON {
        switch self {
        case .int(let i):
            return .integer(i)
        case .uint(let u):
            return .integer(Int64(u))
        case .float(let f):
            return .double(Double(f))
        case .double(let d):
            return .double(d)
        }
    }
}
