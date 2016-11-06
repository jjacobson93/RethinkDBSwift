import PackageDescription

let package = Package(
    name: "RethinkDBSwift",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/BlueSocket", majorVersion: 0, minor: 10),
        .Package(url: "https://github.com/IBM-Swift/BlueCryptor", majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/jjacobson93/WarpCore", majorVersion: 0)
    ]
)
