// swift-tools-version:5.6

import PackageDescription

let pkgName = "SwiftLibXML"

#if compiler(>=6.2)
let packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/mipalgu/swift-docc-static.git", branch: "main")
]
#else
let packageDependencies = [Package.Dependency]()
#endif

// On Windows, SPM's pkg-config support does not interoperate with MSYS2's
// pkgconf: the flag allowlist rejects POSIX-style paths such as
// /mingw64/include/libxml2.  The standard workaround (following
// swift-corelibs-foundation) is to treat CLibXML2 as a regular C target
// driven by environment variables rather than a systemLibrary with pkgConfig.
//
// Consequence: on Windows, CLibXML2 (and therefore SwiftLibXML) is built with
// unsafeFlags.  SPM refuses to build a package that uses unsafeFlags when it
// is fetched as a *remote* dependency, so SwiftLibXML cannot be consumed as a
// remote Swift package on Windows.  Downstream packages must reference it as a
// *local* (path-based) dependency.  See README.md for full details.

#if os(Windows)
let libxmlIncludePath = Context.environment["LIBXML_INCLUDE_PATH"]
    .map { $0.trimmingCharacters(in: .whitespaces) }
let libxmlLibraryPath = Context.environment["LIBXML_LIBRARY_PATH"]
    .map { $0.trimmingCharacters(in: .whitespaces) }
let deps: [Target.Dependency] = [.target(name: "CLibXML2")]
let cTargets: [Target] = [
    .target(
        name: "CLibXML2",
        path: "Sources/CLibXML2",
        sources: ["stub.c"],          // stub needed; SPM requires ≥1 source file
        publicHeadersPath: ".",
        cSettings: libxmlIncludePath.map { [.unsafeFlags(["-I\($0)", "-I\($0)/libxml2"])] } ?? [],
        linkerSettings: {
            // lld-link (used by Swift on Windows) requires an MSVC-compatible
            // import library (xml2.lib).  A workflow step generates it from
            // the DLL using llvm-dlltool (bundled with Swift).
            var s: [LinkerSetting] = [.linkedLibrary("xml2")]
            if let p = libxmlLibraryPath { s += [.unsafeFlags(["-L\(p)"])] }
            return s
        }()
    )
]
#elseif os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
let deps = [Target.Dependency]()
let cTargets = [Target]()
#else
// Linux and other POSIX platforms: use pkg-config as normal.
let deps: [Target.Dependency] = [.target(name: "CLibXML2")]
let cTargets: [Target] = [
    .systemLibrary(
        name: "CLibXML2",
        pkgConfig: "libxml-2.0",
        providers: [
            .brew(["libxml2"]),
            .apt(["libxml2-dev"]),
        ]
    )
]
#endif

#if os(Windows)
// The include path must also be forwarded to the Swift compiler so it can
// build the CLibXML2 clang module (cSettings alone do not propagate there).
let swiftLibXMLSwiftSettings: [SwiftSetting] =
    libxmlIncludePath.map { [.unsafeFlags(["-Xcc", "-I\($0)", "-Xcc", "-I\($0)/libxml2"])] } ?? []
#else
let swiftLibXMLSwiftSettings = [SwiftSetting]()
#endif

let package = Package(
    name: pkgName,
    products: [.library(name: pkgName, targets: [pkgName])],
    dependencies: packageDependencies,
    targets: cTargets + [
        .target(name: pkgName, dependencies: deps,
                swiftSettings: swiftLibXMLSwiftSettings),
        .testTarget(name: "\(pkgName)Tests", dependencies: [.target(name: pkgName)]),
    ]
)
