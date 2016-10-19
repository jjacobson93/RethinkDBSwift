import Foundation

public enum TableReadMode: String {
    case single = "single"
    case majority = "majority"
    case outdated = "outdated"
}

public enum TableIdentifierFormat: String {
    case name = "name"
    case uuid = "uuid"
}

public enum Format: String {
    case native = "native"
    case raw = "raw"
}

/** Optional arguments are instances of Arg. */
public protocol Arg {
    var serialization: (String, ReqlSerializable) { get }
}

public class OptArgs<T: Arg>: ReqlSerializable {
    var dict = [String: ReqlSerializable]()
    public var json: Any {
        var json = [String: Any]()
        for (key, value) in self.dict {
            json[key] = value.json
        }
        return json
    }

    init(_ args: [T]) {
        for arg in args {
            self.setArg(arg)
        }
    }
    
    public func contains(key: String) -> Bool {
        return self.dict.keys.contains(key)
    }
    
    public func setArg(_ arg: T) {
        let (key, value) = arg.serialization
        self.dict[key] = value
    }
    
    public func get<T>(key: String) -> T? {
        return self.dict[key] as? T
    }
}

public enum GlobalArg: Arg {
    case readMode(TableReadMode)
    case timeFormat(Format)
    case profile(Bool)
    case durability(TableDurability)
    case groupFormat(Format)
    case noReply(Bool)
    case db(ReqlQueryDatabase)
    case arrayLimit(Int)
    case binaryFormat(Format)
    case minBatchRows(Int)
    case maxBatchRows(Int)
    case maxBatchBytes(Int)
    case maxBatchSeconds(Double)
    case firstBatchScaledownFactor(Int)

    public var serialization: (String, ReqlSerializable) {
        switch self {
            case .readMode(let tableReadMode): return ("read_mode", tableReadMode.rawValue)
            case .timeFormat(let format): return ("time_format", format.rawValue)
            case .profile(let bool): return ("profile", bool)
            case .durability(let tableDurability): return ("durability", tableDurability.rawValue)
            case .groupFormat(let format): return ("group_format", format.rawValue)
            case .noReply(let bool): return ("noreply", bool)
            case .db(let db): return ("db", db)
            case .arrayLimit(let int): return ("array_limit", int)
            case .binaryFormat(let format): return ("binary_format", format.rawValue)
            case .minBatchRows(let int): return ("min_batch_rows", int)
            case .maxBatchRows(let int): return ("max_batch_rows", int)
            case .maxBatchBytes(let int): return ("max_batch_bytes", int)
            case .maxBatchSeconds(let double): return ("max_batch_seconds", double)
            case .firstBatchScaledownFactor(let int): return ("first_batch_scaledown_factor", int)
        }
    }
}

/** Optional arguments for the R.table command. */
public enum TableArg: Arg {
    case readMode(TableReadMode)
    case identifierFormat(TableIdentifierFormat)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .readMode(let rm): return ("read_mode", rm.rawValue)
        case .identifierFormat(let i): return ("identifier_format", i.rawValue)
        }
    }
}

public enum FilterArg: Arg {
    case `default`(ReqlSerializable)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .default(let a): return ("default", a)
        }
    }
}

public enum TableDurability: String {
    case soft = "soft"
    case hard = "hard"
}

public enum TableCreateArg: Arg {
    case primaryKey(String)
    case durability(TableDurability)
    case shards(Int)
    case replicas(Int)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .primaryKey(let p): return ("primary_key", p)
        case .durability(let d): return ("durability", d.rawValue)
        case .shards(let s): return ("shards", s)
        case .replicas(let r): return ("replicas", r)
        }
    }
}

public enum IndexCreateArg: Arg {
    case multi(Bool)
    case geo(Bool)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .multi(let m): return ("multi", m)
        case .geo(let g): return ("geo", g)
        }
    }
}

public enum IndexRenameArg: Arg {
    /** If the optional argument overwrite is specified as true, a previously existing index with the new name will be 
    deleted and the index will be renamed. If overwrite is false (the default) an error will be raised if the new index 
    name already exists. */
    case overwrite(Bool)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .overwrite(let o): return ("overwrite", o)
        }
    }
}

public enum Permission: Arg {
    case read(Bool)
    case write(Bool)
    case connect(Bool)
    case config(Bool)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .read(let b): return ("read", b)
        case .write(let b): return ("write", b)
        case .connect(let b): return ("connect", b)
        case .config(let b): return ("config", b)
        }
    }
}

public enum ChangesArg: Arg {
    /** squash: Controls how change notifications are batched. Acceptable values are true, false and a numeric value:
    - true: When multiple changes to the same document occur before a batch of notifications is sent, the changes are 
      "squashed" into one change. The client receives a notification that will bring it fully up to date with the server.
    - false: All changes will be sent to the client verbatim. This is the default.
    - n: A numeric value (floating point). Similar to true, but the server will wait n seconds to respond in order to 
      squash as many changes together as possible, reducing network traffic. The first batch will always be returned 
      immediately. */
    case squash(Bool, n: Double?)

    /** ChangefeedQueueSize: the number of changes the server will buffer between client reads before it starts dropping 
    changes and generates an error (default: 100,000). */
    case changeFeedQueueSize(Int)

    /** IncludeInitial: if true, the changefeed stream will begin with the current contents of the table or selection 
    being monitored. These initial results will have new_val fields, but no old_val fields. The initial results may be 
    intermixed with actual changes, as long as an initial result for the changed document has already been given. If an 
    initial result for a document has been sent and a change is made to that document that would move it to the unsent 
    part of the result set (e.g., a changefeed monitors the top 100 posters, the first 50 have been sent, and poster 48 
    has become poster 52), an “uninitial” notification will be sent, with an old_val field but no new_val field.*/
    case includeInitial(Bool)

    /** IncludeStates: if true, the changefeed stream will include special status documents consisting of the field state
    and a string indicating a change in the feed’s state. These documents can occur at any point in the feed between the 
    notification documents described below. If IncludeStates is false (the default), the status documents will not be sent.*/
    case includeStates(Bool)

    /** IncludeOffsets: if true, a changefeed stream on an orderBy.limit changefeed will include old_offset and new_offset 
    fields in status documents that include old_val and new_val. This allows applications to maintain ordered lists of the
    stream’s result set. If old_offset is set and not null, the element at old_offset is being deleted; if new_offset is 
    set and not null, then new_val is being inserted at new_offset. Setting IncludeOffsets to true on a changefeed that 
    does not support it will raise an error.*/
    case includeOffsets(Bool)

    /** includeTypes: if true, every result on a changefeed will include a type field with a string that indicates the 
    kind of change the result represents: add, remove, change, initial, uninitial, state. Defaults to false.*/
    case includeTypes(Bool)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .squash(let b, let i):
            assert(!(i != nil && !b), "Do not specify a time interval when squashing is to be disabled")
            if let interval = i, b {
                 return ("squash", interval)
            }
            else {
                return ("squash", b)
            }

        case .changeFeedQueueSize(let i): return ("changefeed_queue_size", i)
        case .includeInitial(let b): return ("include_initial", b)
        case .includeStates(let b): return ("include_states", b)
        case .includeOffsets(let b): return ("include_offsets", b)
        case .includeTypes(let b): return ("include_types", b)
        }
    }
}

public enum FoldArg: Arg {
    /** When an emit function is provided, fold will:
    - proceed through the sequence in order and take an initial base value, as above.
    - for each element in the sequence, call both the combining function and a separate emitting function with the current 
      element and previous reduction result.
    - optionally pass the result of the combining function to the emitting function.
    If provided, the emitting function must return a list. */
    case emit(ReqlQueryLambda)
    case finalEmit(ReqlQueryLambda)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .emit(let r): return ("emit", r)
        case .finalEmit(let r): return ("final_emit", r)
        }
    }
}

public enum EqJoinArg: Arg {
    /** The results from eqJoin are, by default, not ordered. The optional ordered: true parameter will cause eqJoin to 
    order the output based on the left side input stream. (If there are multiple matches on the right side for a document 
    on the left side, their order is not guaranteed even if ordered is true.) Requiring ordered results can significantly 
    slow down eqJoin, and in many circumstances this ordering will not be required. (See the first example, in which 
    ordered results are obtained by using orderBy after eqJoin.) */
    case ordered(Bool)
    case index(String)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .ordered(let o): return ("ordered", o)
        case .index(let i): return ("index", i)
        }
    }
}

public enum Durability: String {
    case hard = "hard"
    case soft = "soft"
}

public enum ConflictResolution: String {
    /** Do not insert the new document and record the conflict as an error. This is the default. */
    case error = "error"

    /** Replace the old document in its entirety with the new one. */
    case replace = "replace"

    /** Update fields of the old document with fields from the new one. */
    case update = "update"
}

public enum InsertArg: Arg {
    /** This option will override the table or query’s durability setting (set in run). In soft durability mode RethinkDB 
    will acknowledge the write immediately after receiving and caching it, but before the write has been committed to disk. */
    case durability(Durability)

    /** true: return a changes array consisting of old_val/new_val objects describing the changes made, only including the 
    documents actually updated. false: do not return a changes array (the default). */
    case returnChanges(Bool)

    /** Determine handling of inserting documents with the same primary key as existing entries.  */
    case conflict(ConflictResolution)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .durability(let d): return ("durability", d.rawValue)
        case .returnChanges(let r): return ("return_changes", r)
        case .conflict(let r): return ("conflict", r.rawValue)
        }
    }
}

public enum UpdateArg: Arg {
    /** This option will override the table or query’s durability setting (set in run). In soft durability mode RethinkDB
    will acknowledge the write immediately after receiving and caching it, but before the write has been committed to disk. */
    case durability(Durability)

    /** true: return a changes array consisting of old_val/new_val objects describing the changes made, only including the
    documents actually updated. false: do not return a changes array (the default). */
    case returnChanges(Bool)

    /** If set to true, executes the update and distributes the result to replicas in a non-atomic fashion. This flag is 
    required to perform non-deterministic updates, such as those that require reading data from another table. */
    case nonAtomic(Bool)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .durability(let d): return ("durability", d.rawValue)
        case .returnChanges(let r): return ("return_changes", r)
        case .nonAtomic(let b): return ("non_atomic", b)
        }
    }
}

public enum DeleteArg: Arg {
    /** This option will override the table or query’s durability setting (set in run). In soft durability mode RethinkDB
    will acknowledge the write immediately after receiving and caching it, but before the write has been committed to disk. */
    case durability(Durability)

    /** true: return a changes array consisting of old_val/new_val objects describing the changes made, only including the
    documents actually updated. false: do not return a changes array (the default). */
    case returnChanges(Bool)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .durability(let d): return ("durability", d.rawValue)
        case .returnChanges(let r): return ("return_changes", r)
        }
    }
}

public enum SliceArg: Arg {
    case leftBound(RangeInclusion)
    case rightBound(RangeInclusion)
    
    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .leftBound(let r): return ("left_bound", r.rawValue)
        case .rightBound(let r): return ("right_bound", r.rawValue)
        }
    }
}

public enum RangeInclusion: String {
    case open = "open"
    case closed = "closed"
}

public enum Unit: String {
    case meter = "m"
    case kilometer = "km"
    case internationalMile = "mi"
    case nauticalMile = "nm"
    case internationalFoot = "ft"
}

public enum GeoSystem: String {
    case wgs84 = "WGS84"
    case unitSphere = "unit_sphere"
}

public enum CircleArg: Arg {
    /** The number of vertices in the polygon or line. Defaults to 32. */
    case numVertices(Int)

    /** The reference ellipsoid to use for geographic coordinates. Possible values are WGS84 (the default), a common 
    standard for Earth’s geometry, or unit_sphere, a perfect sphere of 1 meter radius. */
    case geoSystem(GeoSystem)

    /** Unit for the radius distance. */
    case unit(Unit)

    /** If true (the default) the circle is filled, creating a polygon; if false the circle is unfilled (creating a line). */
    case fill(Bool)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .numVertices(let n): return ("num_vertices", n)
        case .geoSystem(let s): return ("geo_system", s.rawValue)
        case .unit(let u): return ("unit", u.rawValue)
        case .fill(let b): return ("fill", b)
        }
    }
}

public enum DistanceArg: Arg {
    case geoSystem(GeoSystem)
    case unit(Unit)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .geoSystem(let s): return ("geo_system", s.rawValue)
        case .unit(let u): return ("unit", u.rawValue)
        }
    }
}

public enum IntersectingArg: Arg {
    /** The index argument is mandatory. This command returns the same results as 
    table.filter(r.row('index').intersects(geometry)). The total number of results is limited to the array size limit which 
    defaults to 100,000, but can be changed with the arrayLimit option to run. */
    case index(String)

    public var serialization: (String, ReqlSerializable) {
        switch self {
        case .index(let s): return ("index", s)
        }
    }
}
