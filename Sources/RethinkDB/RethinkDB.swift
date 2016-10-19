import Foundation

public class RethinkDB {
    public static var r: RethinkDB = RethinkDB()

    public func connect(host: String = "localhost", port: Int32 = 28015, db: String = "", user: String = "admin", password: String = "", protocolVersion: ProtocolVersion = .v1_0) throws -> Connection {
        let conn = try Connection(host: host, port: port, db: db, user: user, password: password, version: protocolVersion)
        try conn.connect()
        return conn
    }

    public func uuid() -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.uuid.rawValue])
    }

    public func db(_ name: String) -> ReqlQueryDatabase {
        return ReqlQueryDatabase(name: name)
    }

    public func dbCreate(_ name: String) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.dbCreate.rawValue, [name]])
    }

    public func dbDrop(_ name: String) -> ReqlQuery {
        return ReqlExpr(json: [ReqlTerm.dbDrop.rawValue, [name]])
    }

    public func dbList() -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.dbList.rawValue])
    }
    
    public func table(_ name: String, options: TableArg...) -> ReqlQueryTable {
        return ReqlExpr(json: [ReqlTerm.table.rawValue, [name], OptArgs(options).json])
    }

    public func point(_ longitude: Double, latitude: Double) -> ReqlQueryPoint {
        return ReqlQueryPoint(longitude: longitude, latitude:latitude)
    }

    public func expr(_ string: String) -> ReqlExpr {
        return ReqlExpr(string: string)
    }

    public func expr(_ double: Double) -> ReqlExpr {
        return ReqlExpr(double: double)
    }

    public func expr(_ int: Int) -> ReqlExpr {
        return ReqlExpr(int: int)
    }

    public func expr(_ binary: Data) -> ReqlExpr {
        return ReqlExpr(data: binary)
    }

    public func expr(_ date: Date) -> ReqlExpr {
        return ReqlExpr(date: date)
    }

    public func expr(_ bool: Bool) -> ReqlExpr {
        return ReqlExpr(bool: bool)
    }

    public func expr() -> ReqlExpr {
        return ReqlExpr()
    }

    public func expr(_ document: Document) -> ReqlExpr {
        return ReqlExpr(document: document)
    }

    public func expr(_ object: [String: ReqlSerializable]) -> ReqlExpr {
        return ReqlExpr(object: object)
    }

    public func expr(_ array: [ReqlSerializable]) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.makeArray.rawValue, array])
    }

    public func not(_ value: ReqlExpr) -> ReqlExpr {
        return value.not()
    }

    public func random(_ lower: Int, _ upperOpen: Int) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.random.rawValue, [lower, upperOpen]])
    }

    public func random(_ lower: Double, _ upperOpen: Double) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.random.rawValue, [lower, upperOpen], ["float": true]])
    }

    public func random(_ lower: ReqlSerializable, _ upperOpen: ReqlSerializable, float: Bool = false) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.random.rawValue, [lower.json, upperOpen.json], ["float": float]])
    }

    public func random() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.random.rawValue, []])
    }

    public func round(_ value: ReqlExpr) -> ReqlExpr {
        return value.round()
    }

    public func ceil(_ value: ReqlExpr) -> ReqlExpr {
        return value.ceil()
    }

    public func floor(_ value: ReqlExpr) -> ReqlExpr {
        return value.floor()
    }

    public func now() -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.now.rawValue])
    }
    
    public func time(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0, timezone: String) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.time.rawValue, [year, month, day, hour, minute, second, timezone]])
    }
    
    public func epochTime(_ time: Double) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.epochTime.rawValue, [time]])
    }

    public func iso8601(_ date: String) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.iso8601.rawValue, [date]])
    }

    public func error(_ message: String) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.error.rawValue, [message]])
    }

    public func branch(_ test: ReqlExpr, ifTrue: ReqlExpr, ifFalse: ReqlExpr) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.branch.rawValue, [test.json, ifTrue.json, ifFalse.json]])
    }

    public func object(_ pairs: ReqlSerializable...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.object.rawValue, pairs.map({ $0.json })])
    }
    
    public func object(_ dict: [String: ReqlSerializable]) -> ReqlExpr {
        let pairs = dict.flatMap({ [$0.key, $0.value.json] })
        return ReqlExpr(json: [ReqlTerm.object.rawValue, pairs])
    }

    public func range(_ start: ReqlExpr, _ end: ReqlExpr) -> ReqlQuerySequence {
        return ReqlExpr(json: [ReqlTerm.range.rawValue, [start.json, end.json]])
    }

    public func js(_ source: String) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.javaScript.rawValue, [source]])
    }

    public func json(_ source: String) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.json.rawValue, [source]])
    }

    public func grant(_ userName: String, permissions: Permission...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.grant.rawValue, [userName], OptArgs(permissions)])
    }

    public var minVal: ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.minval.rawValue])
    }

    public var maxVal: ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.maxval.rawValue])
    }

    /** Construct a circular line or polygon. A circle in RethinkDB is a polygon or line approximating a circle of a given
     radius around a given center, consisting of a specified number of vertices (default 32).

    The center may be specified either by two floating point numbers, the latitude (−90 to 90) and longitude (−180 to 180) 
    of the point on a perfect sphere (see Geospatial support for more information on ReQL’s coordinate system), or by a 
    point object. The radius is a floating point number whose units are meters by default, although that may be changed 
    with the unit argument. */
    public func circle(_ longitude: ReqlSerializable, latitude: ReqlSerializable, radius: ReqlSerializable, options: CircleArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.circle.rawValue, [longitude.json, latitude.json, radius.json], OptArgs(options)])
    }

    public func circle(_ point: ReqlQueryPoint, radius: ReqlSerializable, options: CircleArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.circle.rawValue, [point.json, radius.json], OptArgs(options)])
    }

    /** Compute the distance between a point and another geometry object. At least one of the geometry objects specified
    must be a point. 
    
    If one of the objects is a polygon or a line, the point will be projected onto the line or polygon assuming a perfect 
    sphere model before the distance is computed (using the model specified with geoSystem). As a consequence, if the 
    polygon or line is extremely large compared to Earth’s radius and the distance is being computed with the default WGS84 
    model, the results of distance should be considered approximate due to the deviation between the ellipsoid and spherical 
    models. */
    public func distance(_ from: ReqlQueryGeometry, to: ReqlQueryGeometry, options: DistanceArg...) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.distance.rawValue, [from.json, to.json], OptArgs(options)])
    }

    /** Convert a GeoJSON object to a ReQL geometry object.

    RethinkDB only allows conversion of GeoJSON objects which have ReQL equivalents: Point, LineString, and Polygon. 
    MultiPoint, MultiLineString, and MultiPolygon are not supported. (You could, however, store multiple points, lines and 
    polygons in an array and use a geospatial multi index with them.)

    Only longitude/latitude coordinates are supported. GeoJSON objects that use Cartesian coordinates, specify an altitude, 
    or specify their own coordinate reference system will be rejected. */
    public func geoJSON(_ json: ReqlSerializable) -> ReqlQueryGeometry {
        return ReqlQueryGeometry(json: [ReqlTerm.geoJSON.rawValue, [json.json]])
    }

    /** Tests whether two geometry objects intersect with one another.  */
    public func intersects(_ geometry: ReqlQueryGeometry, with: ReqlQueryGeometry) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.intersects.rawValue, [geometry.json, with.json]])
    }

    public func line(_ from: ReqlQueryPoint, to: ReqlQueryPoint) -> ReqlQueryLine {
        return ReqlQueryLine(json: [ReqlTerm.line.rawValue, [from.json, to.json]])
    }

    public func asc(key: String) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.asc.rawValue, [key]])
    }

    public func desc(key: String) -> ReqlExpr {
        return ReqlExpr(json: [ReqlTerm.desc.rawValue, [key]])
    }
}
