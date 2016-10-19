import Foundation

extension Value: ExpressibleByIntegerLiteral {
    public init(integerLiteral: Int) {
        self = .number(NSNumber(value: integerLiteral))
    }
}

extension Value: ExpressibleByFloatLiteral {
    public init(floatLiteral: Double) {
        self = .number(NSNumber(value: floatLiteral))
    }
}

extension Value: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self = .string(stringLiteral)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }

    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }
}

extension Value: ExpressibleByBooleanLiteral {
    public init(booleanLiteral: Bool) {
        self = .bool(booleanLiteral)
    }
}

extension Value: ExpressibleByDictionaryLiteral {
    // public init(dictionaryLiteral elements: (String, Value)...) {
    //     self = .document(Document(dictionaryElements: elements))
    // }

    public init(dictionaryLiteral elements: (String, ValueConvertible)...) {
        self = .document(Document(dictionaryElements: elements.map { ($0, $1.reqlValue) }))
    }
}

extension Value: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: ValueConvertible...) {
        self = .array(elements.map { $0.reqlValue } )
    }
}