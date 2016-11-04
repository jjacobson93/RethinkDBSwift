//
//  ReqlQueryGeometry.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 10/17/16.
//
//

import Foundation

public protocol ReqlQueryGeometry: ReqlQuery {}

extension ReqlQueryGeometry {
    /** Compute the distance between a point and another geometry object. At least one of the geometry objects specified
     must be a point.
     
     If one of the objects is a polygon or a line, the point will be projected onto the line or polygon assuming a perfect
     sphere model before the distance is computed (using the model specified with geoSystem). As a consequence, if the
     polygon or line is extremely large compared to Earth’s radius and the distance is being computed with the default WGS84
     model, the results of distance should be considered approximate due to the deviation between the ellipsoid and spherical
     models. */
    public func distance(_ geometry: ReqlQueryGeometry, options: DistanceArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.distance.rawValue, [self.json, geometry.json], OptArgs(options).json])
    }
    
    /** Convert a ReqlSerializable geometry object to a GeoJSON object. */
    public func toGeoJSONReql() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.toGeoJSON.rawValue, [self.json]])
    }
    
    /** Tests whether two geometry objects intersect with one another.  */
    public func intersects(_ geometry: ReqlQueryGeometry) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.intersects.rawValue, [self.json, geometry.json]])
    }
}

public protocol ReqlQueryPolygon: ReqlQueryGeometry {}

public protocol ReqlQueryLine: ReqlQueryGeometry {}

extension ReqlQueryLine {
    /** Convert a Line object into a Polygon object. If the last point does not specify the same coordinates as the first
     point, polygon will close the polygon by connecting them.
     
     Longitude (−180 to 180) and latitude (−90 to 90) of vertices are plotted on a perfect sphere. See Geospatial support
     for more information on ReQL’s coordinate system.
     
     If the last point does not specify the same coordinates as the first point, polygon will close the polygon by
     connecting them. You cannot directly construct a polygon with holes in it using polygon, but you can use polygonSub to
     use a second polygon within the interior of the first to define a hole. */
    public func fill() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.fill.rawValue, [self.json]])
    }
}

public protocol ReqlQueryPoint: ReqlQueryGeometry {
    init(longitude: Double, latitude: Double)
}
