//
//  ReqlExpr.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/19/16.
//
//

import Foundation

public class ReqlExpr: ReqlQuery, ReqlQuerySelection, ReqlQuerySequence, ReqlQueryStream,
    ReqlQueryGroupedStream, ReqlQueryTable, ReqlQueryGeometry, ReqlQueryPolygon, ReqlQueryLine, ReqlQueryPoint,
    ExpressibleByNilLiteral, ExpressibleByStringLiteral, ExpressibleByBooleanLiteral, ExpressibleByArrayLiteral,
    ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, ExpressibleByDictionaryLiteral {
    
    public typealias Element = ReqlSerializable
    public typealias Key = String
    public typealias Value = ReqlSerializable

    public var json: Any
    
    internal static let reqlTypeTime = "TIME"
    internal static let reqlTypeBinary = "BINARY"
    internal static let reqlSpecialKey = "$reql_type$"
    
    internal init(json: Any) {
        self.json = json
    }
    
    internal init() {
        self.json = NSNull()
    }
    
    internal init(string: String) {
        self.json = string
    }
    
    internal init(float: Float) {
        self.json = float
    }
    
    internal init(double: Double) {
        self.json = double
    }
    
    internal init(int: Int) {
        self.json = int
    }
    
    internal init(int: Int32) {
        self.json = int
    }
    
    internal init(int: Int64) {
        self.json = int
    }
    
    internal init(int: UInt) {
        self.json = int
    }
    
    internal init(int: UInt32) {
        self.json = int
    }
    
    internal init(int: UInt64) {
        self.json = int
    }
    
    internal init(number: NSNumber) {
        self.json = number
    }
    
    internal init(bool: Bool) {
        self.json = bool
    }
    
    internal init(array: [ReqlSerializable]) {
        self.json = [ReqlTerm.makeArray.rawValue, array.map({ $0.json })]
    }
    
    internal init(document: Document) {
        var serialized: [String: Any] = [:]
        for (key, value) in document {
            serialized[key] = value.json
        }
        self.json = serialized
    }
    
    internal init(object: [String: ReqlSerializable]) {
        var serialized: [String: Any] = [:]
        for (key, value) in object {
            serialized[key] = value.json
        }
        self.json = serialized
    }
    
    internal init(date: Date) {
        self.json = [ReqlExpr.reqlSpecialKey: ReqlExpr.reqlTypeTime, "epoch_time": date.timeIntervalSince1970, "timezone": "+00:00"]
    }
    
    internal init(data: Data) {
        self.json = [ReqlExpr.reqlSpecialKey: ReqlExpr.reqlTypeBinary, "data": data.base64EncodedString(options: [])]
    }
    
//    internal init(value: ReqlValue) {
//        switch value {
//        case .document(let doc):
//            self.json = ReqlExpr(document: doc).json
//        case .array(let array):
//            self.json = ReqlExpr(array: array).json
//        default:
//            self.json = value.json
//        }
//    }
    
    public convenience required init(longitude: Double, latitude: Double) {
        self.init(json: [ReqlTerm.point.rawValue, [longitude, latitude]])
    }
    
    /** Expressibles **/
    public convenience required init(nilLiteral: ()) {
        self.init()
    }
    
    public convenience required init(stringLiteral value: String) {
        self.init(string: value)
    }
    
    public convenience required init(unicodeScalarLiteral value: String) {
        self.init(string: value)
    }
    
    public convenience required init(extendedGraphemeClusterLiteral value: String) {
        self.init(string: value)
    }
    
    public convenience required init(booleanLiteral value: Bool) {
        self.init(bool: value)
    }
    
    public convenience required init(floatLiteral value: Double) {
        self.init(double: value)
    }
    
    public convenience required init(integerLiteral value: Int64) {
        self.init(int: value)
    }
    
    public convenience required init(arrayLiteral elements: ReqlSerializable...) {
        self.init(array: elements)
    }
    
    public convenience required init(dictionaryLiteral elements: (String, ReqlSerializable)...) {
        var dict = [String: ReqlSerializable]()
        for (key, value) in elements {
            dict[key] = value
        }
        self.init(object: dict)
    }

    /** Math and Logic **/
    
    public func add(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.add.rawValue, [self.json, value.json]])
    }
    
    public func sub(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.sub.rawValue, [self.json, value.json]])
    }
    
    public func mul(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.mul.rawValue, [self.json, value.json]])
    }
    
    public func div(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.div.rawValue, [self.json, value.json]])
    }
    
    public func mod(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.mod.rawValue, [self.json, value.json]])
    }
    
    public func and(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.and.rawValue, [self.json, value.json]])
    }
    
    public func or(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.or.rawValue, [self.json, value.json]])
    }
    
    public func eq(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.eq.rawValue, [self.json, value.json]])
    }
    
    public func ne(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.ne.rawValue, [self.json, value.json]])
    }
    
    public func gt(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.gt.rawValue, [self.json, value.json]])
    }
    
    public func ge(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.ge.rawValue, [self.json, value.json]])
    }
    
    public func lt(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.lt.rawValue, [self.json, value.json]])
    }
    
    public func le(_ value: ReqlSerializable) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.le.rawValue, [self.json, value.json]])
    }
    
    public func not() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.not.rawValue, [self.json]])
    }
    
    public func round() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.round.rawValue, [self.json]])
    }
    
    public func ceil() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.ceil.rawValue, [self.json]])
    }
    
    public func floor() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.floor.rawValue, [self.json]])
    }
    
    /** Document Manipulation **/
    
    /** Dates and Times **/
    
    public func inTimezone(_ timezone: String) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.inTimezone.rawValue, [self.json, timezone]])
    }
    
    public func timezone() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.timezone.rawValue, [self.json]])
    }
    
    public func during(_ startTime: ReqlExpr, _ endTime: ReqlExpr) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.during.rawValue, [self.json, [startTime.json, endTime.json]]])
    }
    
    public func date() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.date.rawValue, [self.json]])
    }
    
    public func timeOfDay() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.timeOfDay.rawValue, [self.json]])
    }
    
    public func year() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.year.rawValue, [self.json]])
    }
    
    public func month() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.month.rawValue, [self.json]])
    }
    
    public func day() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.day.rawValue, [self.json]])
    }
    
    public func dayOfWeek() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.dayOfWeek.rawValue, [self.json]])
    }
    
    public func dayOfYear() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.dayOfYear.rawValue, [self.json]])
    }
    
    public func hours() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.hours.rawValue, [self.json]])
    }
    
    public func minutes() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.minutes.rawValue, [self.json]])
    }
    
    public func seconds() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.seconds.rawValue, [self.json]])
    }
    
    public func toISO8601() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.toISO8601.rawValue, [self.json]])
    }
    
    public func toEpochTime() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.toEpochTime.rawValue, [self.json]])
    }
    
    
    /** Control structures **/
    
    public func defaults(_ value: ReqlExpr) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.default.rawValue, [self.json, value.json]])
    }
    
    public func match(_ value: ReqlExpr) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.match.rawValue, [self.json, value.json]])
    }
    
    public func toJSON() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.toJSONString.rawValue, [self.json]])
    }
    
    public func toJSONString() -> ReqlExpr {
        return self.toJSON()
    }
    
    public func upcase() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.upcase.rawValue, [self.json]])
    }
    
    public func downcase() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.downcase.rawValue, [self.json]])
    }
    
    public func xor(_ other: ReqlExpr) -> ReqlExpr {
        return self.and(other.not()).or(self.not().and(other))
    }
    
    public func merge(_ value: ReqlExpr) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.merge.rawValue, [self.json, value.json]])
    }
    
    public func branch(_ ifTrue: ReqlExpr, _ ifFalse: ReqlExpr) -> ReqlExpr {
        return RethinkDB.r.branch(self, ifTrue: ifTrue, ifFalse: ifFalse)
    }
    
    public func without(fields: [ReqlExpr]) -> ReqlQuerySequence {
        let values = fields.map({ e in return e.json })
        return ReqlExpr(json: [ReqlTerm.without.rawValue, [self.json, [ReqlTerm.makeArray.rawValue, values]]])
    }
    
    /** Subscripts **/
    
    public subscript(key: String) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.bracket.rawValue, [self.json, key]])
    }
}

/** Operators **/
public func +(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.add(rhs)
}

public func -(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.sub(rhs)
}

public func *(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.mul(rhs)
}

public func /(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.div(rhs)
}

public func %(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.mod(rhs)
}

public func &&(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.and(rhs)
}

public func ||(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.or(rhs)
}

public func ==(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.eq(rhs)
}

public func !=(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.ne(rhs)
}

public func >(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.gt(rhs)
}

public func >=(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.ge(rhs)
}

public func <(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.lt(rhs)
}

public func <=(lhs: ReqlExpr, rhs: ReqlSerializable) -> ReqlExpr {
    return lhs.le(rhs)
}

public prefix func !(lhs: ReqlExpr) -> ReqlExpr {
    return lhs.not()
}
