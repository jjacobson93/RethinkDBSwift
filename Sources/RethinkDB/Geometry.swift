//
//  Geometry.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 11/21/16.
//
//

import Foundation

public enum Geometry: CustomStringConvertible {
    case point(Double, Double)
    case line([(Double, Double)])
    case polygon([(Double, Double)])
    
    public var description: String {
        switch self {
        case .point(let long, let lat):
            return "Point(\(long), \(lat))"
        case .line(let points):
            return "Line([\(points.map({ (x, y) in  "(\(x), \(y))" }).joined(separator: ", "))])"
        case .polygon(let points):
            return "Polygon([\(points.map({ (x, y) in  "(\(x), \(y))" }).joined(separator: ", "))])"
        }
    }
    
    public var coordinates: [Any] {
        switch self {
        case .point(let long, let lat):
            return [long, lat]
        case .line(let points):
            return points
        case .polygon(let points):
            return points
        }
    }
    
    public var name: String {
        switch self {
        case .point:
            return "Point"
        case .line:
            return "LineString"
        case .polygon:
            return "Polygon"
        }
    }
    
    public var dictionary: [String: Any] {
        return [
            ReqlType.key: ReqlType.geometry.rawValue,
            "type": self.name,
            "coordinates": self.coordinates
        ]
    }
    
    public static func from(_ reqlObject: [String: Any]) -> Geometry? {
        guard let type = reqlObject["type"] as? String,
            type == "Point" || type == "LineString" || type == "Polygon" else {
            return nil
        }
        
        guard let coordinates = reqlObject["coordinates"] as? [Any] else {
            return nil
        }
        
        if type == "Point" {
            guard coordinates.count == 2 else {
                return nil
            }
            
            if let longitude = coordinates[0] as? Double,
                let latitude = coordinates[1] as? Double {
                return .point(longitude, latitude)
            }
            
            if let longitude = coordinates[0] as? Int64,
                let latitude = coordinates[1] as? Int64 {
                return .point(Double(longitude), Double(latitude))
            }
            
            return nil
        }
        
        let points = coordinates.flatMap({ (arr: Any) -> (Double, Double)? in
            guard let pair = arr as? [Double], pair.count == 2 else {
                return nil
            }
            
            return (pair[0], pair[1])
        })
        
        guard points.count == coordinates.count else {
            return nil
        }
        
        if type == "LineString" {
            // lines must have two or more points
            guard points.count >= 2 else {
                return nil
            }
            
            return .line(points)
        }
        
        // polygons must have three or more points and first and last must be the same
        guard points.count >= 3, let first = points.first, let last = points.last,
            first != last else {
            return nil
        }
        
        return .polygon(points)
    }
}
