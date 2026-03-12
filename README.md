# SwiftLibXML
A small object-oriented Swift API around libxml2.

![macOS](https://github.com/rhx/SwiftLibXML/actions/workflows/macOS.yml/badge.svg?branch=development)
![Linux](https://github.com/rhx/SwiftLibXML/actions/workflows/Linux.yml/badge.svg?branch=development)
![Windows CI](https://github.com/rhx/SwiftLibXML/actions/workflows/windows-ci.yml/badge.svg?branch=development)

SwiftLibXML wraps libxml2 pointers in Swift value and reference types that make
common parsing, traversal, attribute lookup, namespace handling, and XPath
queries straightforward on macOS, Linux, and Windows.

## Quick Start

Add SwiftLibXML to your package:

```swift
.package(url: "https://github.com/rhx/SwiftLibXML.git", from: "3.0.0")
```

Then import the module, parse a document, and run an XPath query:

```swift
import Foundation
import SwiftLibXML

let xml = """
<?xml version="1.0"?>
<greeting language="en">Hello</greeting>
"""

if let document = XMLDocument(data: Data(xml.utf8)) {
    let root = document.rootElement
    print(root.name)                         // greeting
    print(root.content)                      // Hello
    print(root.attribute(named: "language")) // Optional("en")
    if let matches = document.xpath("//greeting") {
        for element in matches {
            print(element.qualifiedName)
        }
    }
}
```

## Features

- Parse XML or HTML from memory or from a file.
- Traverse parents, siblings, children, descendants, attributes, and namespaces.
- Query documents with XPath.
- Keep libxml2 interop explicit without forcing callers to manage raw pointers.

## Requirements

- Swift 5.6 or newer.
- libxml2 development headers and libraries.

## Prerequisites

### Swift

To build, you need at least Swift 5.6. Download Swift from
https://swift.org/download/ and, on macOS, make sure the command line tools are
installed as well. Test that your compiler works using `swift --version`, which
should give you something like

	$ swift --version
	swift-driver version: 1.127.15 Apple Swift version 6.2.4 (swiftlang-6.2.4.1.4 clang-1700.6.4.2)
	Target: arm64-apple-macosx26.0

on macOS, or on Linux you should get something like:

	$ swift --version
	Swift version 6.1 (swift-6.1-RELEASE)
	Target: x86_64-unknown-linux-gnu

### libxml2

#### Linux

On Ubuntu 16.04, 18.04, 20.04, 22.04, and 24.04, you can use the libxml2 that comes with the distribution.  Just install with the `apt` package manager:

	sudo apt update
	sudo apt install libxml2-dev

#### macOS

On macOS, you can install libxml2 using Homebrew (for setup instructions, see
http://brew.sh):

	brew update
	brew install libxml2

#### Windows

On Windows, install libxml2 via [MSYS2](https://www.msys2.org/).  Open an MSYS2 MINGW64 shell and run:

	pacman -S mingw-w64-x86_64-libxml2

Then, before building with Swift, set the following environment variables so that `Package.swift` can locate the headers and library:

	set LIBXML_INCLUDE_PATH=C:\msys64\mingw64\include
	set LIBXML_LIBRARY_PATH=C:\msys64\mingw64\lib
	set PATH=C:\msys64\mingw64\bin;%PATH%

Swift's linker (`lld-link`) requires an MSVC-compatible import library (`xml2.lib`).
MSYS2 ships a GNU-format import library (`libxml2.dll.a`) that lld can read directly; copy it once:

	copy C:\msys64\mingw64\lib\libxml2.dll.a C:\msys64\mingw64\lib\xml2.lib

Then build and test as usual:

	swift build
	swift test

##### Windows dependency caveat

On Windows, `Package.swift` builds `CLibXML2` as a regular Swift target using
`unsafeFlags` (because SPM's `systemLibrary`/`pkgConfig` mechanism does not
interoperate with MSYS2's `pkgconf`).

**Consequence:** SPM refuses to fetch a package that uses `unsafeFlags` as a
*remote* (URL-based) dependency.  If you want to use SwiftLibXML on Windows
you must reference it as a *local* (path-based) dependency in your
`Package.swift`:

```swift
// ✅ Works on Windows
.package(path: "../SwiftLibXML")

// ❌ Does NOT work on Windows (SPM rejects unsafeFlags in remote packages)
.package(url: "https://github.com/rhx/SwiftLibXML.git", from: "…")
```

This restriction applies to Windows only; macOS and Linux consumers can use
the normal remote-package dependency.

## Building

Build the package with:

```bash
swift build
```

Run the test suite with:

```bash
swift test
```

## Generating Documentation

With Swift 6.2 or newer, the package includes the `swift-docc-static` command
plugin dependency. Generate static documentation with:

```bash
swift package generate-static-documentation --output /tmp/swiftlibxml-docs
```

The generated site can then be opened directly from the filesystem, for example
at `/tmp/swiftlibxml-docs/documentation/swiftlibxml/index.html`.
