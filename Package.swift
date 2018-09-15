// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let pkgName = "SwiftLibXML"

let targets: [Target]
#if os(macOS)
    targets = [
        .target(name: pkgName, dependencies: []),
        .testTarget(name: "\(pkgName)Tests", dependencies: [.byNameItem(name: pkgName)]),
    ]
#else
    targets = [
        .target(name: pkgName, dependencies: ["libxml2"]),
        .systemLibrary(name: "libxml2")
        .testTarget(name: "\(pkgName)Tests", dependencies: [.byNameItem(name: pkgName)]),
    ]
#endif

let package = Package(name: pkgName,
    products: [ .library(name: pkgName, targets: [pkgName]), ],
    dependencies: [],
    targets: [
        .target(name: pkgName, dependencies: []),
        .testTarget(name: "\(pkgName)Tests", dependencies: [.byNameItem(name: pkgName)]),
    ]
)
