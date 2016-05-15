import PackageDescription

let package = Package(
    name: "SwiftLibXML",
    dependencies: [
        .Package(url: "https://github.com/rhx/CLibXML2.git", majorVersion: 1)
    ]
)
