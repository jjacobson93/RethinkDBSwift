import PackageDescription

let package = Package(
    name: "RethinkDBSwift",
    dependencies: [
        // .Package(url: "https://github.com/IBM-Swift/BlueSocket", Version(0, 12, 39)),
        .Package(url: "https://github.com/IBM-Swift/BlueSSLService", Version(0, 12, 30)),
        .Package(url: "https://github.com/IBM-Swift/BlueCryptor", Version(0, 8, 8)),
        .Package(url: "https://github.com/jjacobson93/WarpCore", majorVersion: 0)
    ]
)
