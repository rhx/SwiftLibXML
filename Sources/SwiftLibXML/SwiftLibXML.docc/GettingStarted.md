# Getting Started with SwiftLibXML

Add SwiftLibXML to a package and parse your first XML document.

## Add the Dependency

Add SwiftLibXML to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/rhx/SwiftLibXML.git", from: "2.0.0"),
],
targets: [
    .target(
        name: "MyTarget",
        dependencies: [
            .product(name: "SwiftLibXML", package: "SwiftLibXML")
        ]
    ),
]
```

Then import the module at the top of any Swift file:

```swift
import SwiftLibXML
```

> Note: If your target also imports `Foundation`, qualify the document type as
> `SwiftLibXML.XMLDocument` wherever you create one. Foundation declares its
> own `XMLDocument` type, and the Swift compiler cannot resolve the ambiguity
> automatically.

## Parse an XML Document

Create an ``XMLDocument`` from UTF-8 encoded `Data`. The initialiser returns
`nil` when parsing fails completely (malformed input that the error-recovery
pass cannot salvage).

```swift
import Foundation
import SwiftLibXML

let xml = """
<?xml version="1.0" encoding="UTF-8"?>
<catalogue>
  <book id="1">
    <title>Clean Code</title>
    <author>Robert C. Martin</author>
  </book>
  <book id="2">
    <title>The Swift Programming Language</title>
    <author>Apple Inc.</author>
  </book>
</catalogue>
"""

guard let document = SwiftLibXML.XMLDocument(data: Data(xml.utf8)) else {
    print("Parse failed")
    return
}
```

## Read the Root Element

``XMLDocument/rootElement`` gives you the document root as an ``XMLElement``:

```swift
let root = document.rootElement
print(root.name)   // catalogue
```

## Walk Child Elements

``XMLElement/children`` iterates the immediate children. Because libxml2
stores whitespace between tags as text nodes, the sequence includes both
element nodes and text nodes. Filter on ``XMLElement/name`` to keep only
the nodes you care about:

```swift
for element in root.children where element.name != "text" {
    let id = element.attribute(named: "id") ?? "?"
    print("\(element.name) id=\(id)")
}
// book id=1
// book id=2
```

## Query with XPath

``XMLDocument/xpath(_:namespaces:defaultPrefix:)`` compiles an XPath
expression and returns an ``XMLPath`` collection. XPath expressions select
element nodes only, which avoids text-node filtering altogether:

```swift
if let titles = document.xpath("//title") {
    for title in titles {
        print(title.content)
    }
}
// Clean Code
// The Swift Programming Language
```

## Next Steps

- <doc:ParsingAndTraversal> — tree iteration strategies in depth
- <doc:XPathQueries> — predicate expressions and result collections
- <doc:WorkingWithNamespaces> — namespace-aware queries
