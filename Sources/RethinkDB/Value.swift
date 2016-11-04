import Foundation

public enum Value {
    case number(NSNumber)
    case string(String)
    case document(Document)
    case array([Value])
    case date(Date)
    case data(Data)
    case bool(Bool)
    case null
    case nothing
}

extension Value: ReqlSerializable, CustomStringConvertible, CustomDebugStringConvertible {

    public init(_ value: Any) {
        if let value = value as? [Any] {
            var array = [ReqlValue]()
            for e in value {
                let reqlValue = ReqlValue(e)
                if case .nothing = reqlValue {
                    self = .nothing
                    return
                }
                array.append(reqlValue)
            }
            self = .array(array)
            return
        }

        if let value = value as? [String: Any] {
            if let reqlType = value[ReqlExpr.reqlSpecialKey] as? String {
                if reqlType == ReqlExpr.reqlTypeTime {
                    self = .date(Date.from(value))
                    return
                }

                if reqlType == ReqlExpr.reqlTypeBinary {
                    self = .data(Data.from(value))
                    return
                }
            }


            var dict = [String: Value]()
            for (k, v) in value {
                let reqlValue = ReqlValue(v)
                if case .nothing = reqlValue {
                    self = .nothing
                    return
                }

                dict[k] = reqlValue
            }
            self = .document(Document(dict))
            return
        }
        
        // Bool is a special case. Converting to a ValueConvertible will convert into NSNumber
        if let value = value as? Bool {
            self = .bool(value)
            return
        }

        if let value = value as? ValueConvertible {
            self = value.reqlValue
            return
        }

        self = .nothing
    }
    
    public var isNothing: Bool {
        if case .nothing = self {
            return true
        }
        return false
    }
    
    public var hasValue: Bool {
        return !self.isNothing
    }

    public var json: Any {
        switch self {
        case .number(let v): return v
        case .string(let v): return v
        case .document(let v): return v.json
        case .array(let v): return [ReqlTerm.makeArray.rawValue, v.map { $0.json }]
        case .data(let v): return Document([ReqlExpr.reqlSpecialKey: ReqlExpr.reqlTypeBinary, "data": v.base64EncodedString(options: [])]).json
        case .date(let v): return Document([ReqlExpr.reqlSpecialKey: ReqlExpr.reqlTypeTime, "epoch_time": v.timeIntervalSince1970, "timezone": "+00:00"]).json
        case .bool(let v): return v
        case .null, .nothing: return NSNull()
        }
    }

    public var description: String {
        switch self {
        case .number(let v): return v.description
        case .string(let v): return v.description
        case .document(let v): return v.description
        case .array(let v): return v.description
        case .data(let v):
            let bytes = [UInt8](v[0..<(v.count > 6 ? 6 : v.count)])
            let bytesString = bytes.map({ "\($0 < 10 ? "0" : "")\($0)" }).joined(separator: " ")
            return "<binary, \(v), \"\(bytesString)\(v.count > 6 ? " ..." : "")\">"
        case .date(let v):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return "Date(\"\(formatter.string(from: v))\")"
        case .bool(let v): return v.description
        case .null: return "<null>"
        case .nothing: return "<nothing>"
        }
    }

    public var debugDescription: String {
        switch self {
        case .number(let v): return v.debugDescription
        case .string(let v): return v.debugDescription
        case .document(let v): return v.debugDescription
        case .array(let v): return v.debugDescription
        case .data: return self.description
        case .date: return self.description
        case .bool(let v): return v ? "true" : "false"
        case .null: return "<null>"
        case .nothing: return "<nothing>"
        }
    }

    public var int: Int {
        switch self {
        case .number(let v): return v.intValue
        default: return 0
        }
    }

    public var double: Double {
        switch self {
        case .number(let v): return v.doubleValue
        default: return 0
        }
    }
    
    public var string: String {
        switch self {
        case .string(let v): return v
        default: return ""
        }
    }

    public var array: [Value] {
        switch self {
        case .array(let v): return v
        default: return []
        }
    }
    
    public var document: Document {
        switch self {
        case .document(let v): return v
        default: return Document()
        }
    }

    public var date: Date {
        switch self {
        case .date(let v): return v
        default: return Date()
        }
    }
    
    public var data: Data {
        switch self {
        case .data(let v): return v
        default: return Data()
        }
    }

    public var bool: Bool {
        switch self {
        case .bool(let v): return v
        default: return false
        }
    }

    public var storedValue : Any? {
        switch self {
        case .number(let val): return val
        case .string(let val): return val
        case .document(let val): return val
        case .array(let val): return val
        case .date(let val): return val
        case .data(let val): return val
        case .bool(let val): return val
        case .null, .nothing: return nil
        }
    }
    
    public var intValue: Int? {
        return (self.storedValue as? NSNumber)?.intValue
    }
    
    public var uintValue: UInt? {
        return (self.storedValue as? NSNumber)?.uintValue
    }

    public var doubleValue: Double? {
        return (self.storedValue as? NSNumber)?.doubleValue
    }
    
    public var floatValue: Float? {
        return (self.storedValue as? NSNumber)?.floatValue
    }

    public var stringValue: String? {
        return self.storedValue as? String
    }

    public var arrayValue: [ReqlValue]? {
        return self.storedValue as? [ReqlValue]
    }

    public var documentValue: Document? {
        return self.storedValue as? Document
    }

    public var dateValue: Date? {
        return self.storedValue as? Date
    }

    public var dataValue: Data? {
        return self.storedValue as? Data
    }

    public var boolValue: Bool? {
        return self.storedValue as? Bool
    }
}

// For dumb reasons
public typealias ReqlValue = Value
