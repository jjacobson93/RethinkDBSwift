import Foundation

public protocol ReqlSerializable {
    var json: Any { get }
}

extension String: ReqlSerializable {
    public var json: Any {
        return self
    }
}

extension Bool: ReqlSerializable {
    public var json: Any {
        return self
    }
}

extension Int: ReqlSerializable {
    public var json: Any {
        return self
    }
}

extension Int32: ReqlSerializable {
    public var json: Any {
        return self
    }
}

extension Int64: ReqlSerializable {
    public var json: Any {
        return self
    }
}

extension Double: ReqlSerializable {
    public var json: Any {
        return self
    }
}

extension Float: ReqlSerializable {
    public var json: Any {
        return self
    }
}

extension Array where Element: ReqlSerializable {
    public var json: Any {
        return [ReqlTerm.makeArray.rawValue, self]
    }
}

extension Dictionary: ReqlSerializable {
    public var json: Any {
        return self
    }
}

// MARK: Pseudo-types

extension Data: ReqlSerializable {
    public var json: Any {
        return [
            ReqlType.key: ReqlType.binary.rawValue,
            "data": self.base64EncodedString()
        ]
    }
}

extension Date: ReqlSerializable {
    public var json: Any {
        return [
            ReqlType.key: ReqlType.time.rawValue,
            "epoch_time": self.timeIntervalSince1970,
            "timezone": "+00:00"
        ]
    }
}

extension Geometry: ReqlSerializable {
    public var json: Any {
        switch self {
        case .point(let long, let lat):
            return [ReqlTerm.point.rawValue, [long, lat]]
        case .line(let points):
            return [ReqlTerm.line.rawValue, points]
        case .polygon(let points):
            return [ReqlTerm.polygon.rawValue, points]
        }
    }
}
