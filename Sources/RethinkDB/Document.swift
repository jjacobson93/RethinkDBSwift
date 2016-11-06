import Foundation
import WarpCore

// protocol DocumentProtocol {
//     associatedtype Key
// }
public protocol __DocumentProtocolForArrayAdditions {
    init(element: Any)
}

extension Document : __DocumentProtocolForArrayAdditions {}

extension Array where Element : __DocumentProtocolForArrayAdditions {
    public init(array: [Any]) {
        var elements = [Element]()

        for element in array {
            elements.append(Element(element: element))
        }

        self = elements
    }
}

public struct Document: Collection, ExpressibleByDictionaryLiteral, ReqlSerializable, CustomStringConvertible, CustomDebugStringConvertible, JSONRepresentable {
    public typealias Element = (key: String, value: Value)
    public struct Index: Comparable {
        let key: String
        let value: Value

        init(key: String, value: Value) {
            self.key = key
            self.value = value
        }

        public static func <(i: Index, j: Index) -> Bool {
            return i.key < j.key
        }

        public static func ==(i: Index, j: Index) -> Bool {
            return i.key == j.key
        }
    }

    public struct Iterator: IteratorProtocol {
        public typealias Element = Document.Element

        let document: Document
        var dictIterator: DictionaryIterator<String, Value>

        init(_ document: Document) {
            self.document = document
            self.dictIterator = document.storage.makeIterator()
        }

        public mutating func next() -> (key: String, value: Value)? {
            return self.dictIterator.next()
        }
    }

    internal var storage: [String: Value]

    public var json: Any {
        var jsonDict = [String: Any]()
        for (key, value) in self.storage {
            jsonDict[key] = value.json
        }

        return jsonDict
    }

    public var description: String {
        return self.storage.description
    }

    public var debugDescription: String {
        return self.storage.debugDescription
    }

    public init() {
        self.storage = [:]
    }
    
    public init(document: Document) {
        self.init()
        for (key, value) in document {
            self[key] = value
        }
    }

    public init(_ dictionary: [String: ValueConvertible]) {
        self.init()
        for (key, value) in dictionary {
            self[key] = value.reqlValue
        }
    }

    public init(dictionaryElements elements: [(String, Value)]) {
        self.init()
        for (key, value) in elements {
            self[key] = value
        }
    }

    public init(element: Any) {
        if let document = element as? Document {
            self.init(document: document)
            return
        }
        
        self.init()
        guard let elements = element as? [String: Any] else {
            return
        }

        for (key, value) in elements {
            self[key] = ReqlValue(value)
        }
    }

    public init(dictionaryLiteral elements: (String, ValueConvertible)...) {
        self.init(dictionaryElements: elements.map { ($0, $1.reqlValue) })
    }
    
    public func encoded() -> JSON {
        return JSON(self.json)
    }
    
//    public required convenience init(dictionaryLiteral elements: (String, Any)...) {
//        self.init(dictionaryElements: elements.flatMap {
//            if let value = $1 as? ValueConvertible {
//                return ($0, value.reqlValue)
//            }
//            
//            return nil
//        })
//    }

    public var startIndex: Index {
        let (key, value) = self.storage[self.storage.startIndex]
        return Index(key: key, value: value)
    }

    public var endIndex: Index {
        let (key, value) = self.storage[self.storage.endIndex]
        return Index(key: key, value: value)
    }
    
    public func get<T>(_ key: String) -> T? {
        if let value = self[key].storedValue {
            return value as? T
        }
        
        return nil
    }

    public subscript(key: String) -> ReqlValue {
        get {
            if let value = self.storage[key] {
                return value
            }

            return ReqlValue.nothing
        }

        set(value) {
            self.storage[key] = value
        }
    }
    
    public subscript(index: Index) -> Iterator.Element {
        return (index.key, index.value)
    }

    public func index(after i: Index) -> Index {
        let storageIndex = self.storage.index(forKey: i.key)!
        let (key, value) = self.storage[self.storage.index(after: storageIndex)]
        return Index(key: key, value: value)
    }

    public func makeIterator() -> Document.Iterator {
        return Document.Iterator(self)
    }

    // @discardableResult public mutating func removeValue(forKey key: String) -> Value? {

    // }
}
