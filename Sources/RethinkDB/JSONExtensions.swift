//
//  JSONExtensions.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/19/16.
//
//

import Foundation
import WarpCore

extension JSON {
    
    init(_ value: Any) {
        if let d = value as? [String: Any] {
            self = JSON(d)
            return
        }
        
        if let a = value as? [Any] {
            self = JSON(a)
            return
        }
    
        guard let jsonValue = value as? JSONRepresentable else {
            self = .null
            return
        }
        
        self = JSON(jsonValue)
    }
    
    init(_ dictionary: [String: Any]) {
        var jsonDict = [String: JSON]()
        for (key, value) in dictionary {
            jsonDict[key] = JSON(value)
        }
        
        self = .object(jsonDict)
    }
    
    init(_ array: [Any]) {
        var jsonArray = [JSON]()
        for value in array {
            jsonArray.append(JSON(value))
        }
        
        self = .array(jsonArray)
    }
    
    static func data(with object: Any) throws -> Data {
        if let data = try JSON(object).serialized().data(using: .utf8) {
            return data
        }
        
        throw JSON.Parser.Error.Reason.invalidUnicode
    }
    
    static func from(_ data: Data) throws -> JSON {
        let string = String(data: data, encoding: .utf8) ?? ""
        return try JSON.Parser.parse(string)
    }
    
    func decode() -> Any {
        switch self {
        case .array(let arr):
            return arr.map({ $0.decode() })
        case .bool(let b):
            return b
        case .double(let d):
            return d
        case .integer(let i):
            return i
        case .object(let obj):
            var dict = [String: Any]()
            for (key, value) in obj {
                dict[key] = value.decode()
            }
            return dict
        case .string(let s):
            return s
        case .null:
            return NSNull()
        }
    }
}
