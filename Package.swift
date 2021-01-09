// swift-tools-version:5.2

import PackageDescription

let pkgName = "SwiftLibXML"

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
let deps = [Target.Dependency]()
let cTargets = [Target]()
#else
let deps: [Target.Dependency] = [ .target(name: "CLibXML2") ]
let cTargets: [Target] = [
    .systemLibrary(name: "CLibXML2", pkgConfig: "libxml-2.0",
                  providers: [
                    .brew(["libxml2"]),
                    .apt(["libxml2-dev"])
    ])
]
#endif

let package = Package(name: pkgName,
    products: [ .library(name: pkgName, targets: [pkgName]), ],
    targets: cTargets + [
        .target(name: pkgName, dependencies: deps),
        .testTarget(name: "\(pkgName)Tests", dependencies: [.target(name: pkgName)]),
    ]
)
