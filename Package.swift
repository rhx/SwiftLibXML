// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let pkgName = "SwiftLibXML"

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
let deps = [Package.Dependency]()
#else
let deps: [Package.Dependency] = [ .package(url: "https://github.com/rhx/CLibXML2.git", from: "1.0.0"), ]
#endif

let package = Package(name: pkgName,
    products: [ .library(name: pkgName, targets: [pkgName]), ],
    dependencies: deps,
    targets: [
        .target(name: pkgName, dependencies: []),
        .testTarget(name: "\(pkgName)Tests", dependencies: [.byNameItem(name: pkgName)]),
    ]
)
