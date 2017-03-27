RethinkDBSwift
==============
![macOS](https://img.shields.io/badge/os-macOS-green.svg)
![Linux](https://img.shields.io/badge/os-Linux-green.svg)
![Swift](https://img.shields.io/badge/swift-3.0-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A driver for [RethinkDB](https://rethinkdb.com/) written in Swift.

## Usage
### Import the module
```swift
import RethinkDB
```

### Create a new connection
```swift
let r = RethinkDB.r
let conn = try! r.connect()
```

### Connection pool
```swift
let pool = try! r.pool(size: 15) // creates a connection pool with 15 connections
let conn = try! pool.acquire() // or acquire(timeout: secondsUntilTimeout)
// do stuff with the connection
pool.release(connection: conn)
```

### Query the database
```swift
let locations: Cursor<Document> = try! r.db("test").table("locations").run(conn)
for location in locations {
    // do stuff here
}
```

### Insert records
```swift
let location: Document = ["lat": 46.944, "long": 7.447]
try! r.db("test").table("locations").insert(location).run(conn)

let numbers: [Document] = [
    ["n": 2], ["n": 4], ["n": 8]
]
try! r.db("test").table("numbers").insert(numbers).run(conn)
```

### Further reading
Check out the [API documentation](https://rethinkdb.com/api/) for one of the official drivers.

## License
MIT