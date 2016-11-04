import Foundation

public protocol ValueConvertible {
    var reqlValue: ReqlValue { get }
}

extension Bool: ValueConvertible {
    public var reqlValue: ReqlValue {
        return .bool(self)
    }
}

extension NSNumber: ValueConvertible {
    public var reqlValue: ReqlValue {
        return .number(self)
    }
}

extension Int: ValueConvertible {
    public var reqlValue: ReqlValue {
        return .number(NSNumber(value: self))
    }
}

extension Int64: ValueConvertible {
    public var reqlValue: ReqlValue {
        return .number(NSNumber(value: self))
    }
}

extension Double: ValueConvertible {
    public var reqlValue: ReqlValue {
        return .number(NSNumber(value: self))
    }
}

extension String: ValueConvertible {
    public var reqlValue: ReqlValue {
        return .string(self)
    }
}

extension Document: ValueConvertible {
    public var reqlValue: ReqlValue {
        return .document(self)
    }
}

extension Array: ValueConvertible {
    public var reqlValue: ReqlValue {
        let values = self.map { (value) -> ReqlValue in
            if let vc = value as? ValueConvertible {
                return vc.reqlValue
            }
            return .nothing
        }
        
        return .array(values)
    }
}

extension Date: ValueConvertible {
    public var reqlValue: ReqlValue {
        return .date(self)
    }

    public static func from(_ reqlObject: [String: Any]) -> Date {
        let epochTime = TimeInterval((reqlObject["epoch_time"] as? Double) ?? 0)
        return Date(timeIntervalSince1970: epochTime)
    }
}

extension Data: ValueConvertible {
    public var reqlValue: ReqlValue {
        return .data(self)
    }

    public static func from(_ reqlObject: [String: Any]) -> Data {
        let string = reqlObject["data"] as? String ?? ""
        return Data(base64Encoded: string) ?? Data()
    }
}

extension ReqlValue: ValueConvertible {
    public var reqlValue: ReqlValue {
        return self
    }
}

// Grr: This might be an issue with SwiftyJSON not converting NSString objects
extension NSString: ValueConvertible {
    public var reqlValue: ReqlValue {
        return .string(self.description)
    }
}
