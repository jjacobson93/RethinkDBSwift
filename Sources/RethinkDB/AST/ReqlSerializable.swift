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

extension Array: ReqlSerializable {
    public var json: Any {
        return self
    }
}

extension Dictionary: ReqlSerializable {
    public var json: Any {
        return self
    }
}
