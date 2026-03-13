# Parsing and Traversal

Set up a document, read the root element, and walk the tree.

## Parse XML or HTML

Create an ``XMLDocument`` from `Data`, an in-memory `UnsafeBufferPointer`, or a
file path. The default options suppress warning output, disable network access,
and ask libxml2 to recover where possible.

```swift
import Foundation
import SwiftLibXML

let xmlData = Data("<catalogue><book>Clean Code</book></catalogue>".utf8)
guard let document = SwiftLibXML.XMLDocument(data: xmlData) else {
    // parse failed entirely
    return
}
```

For HTML input, pass ``htmlMemoryParser`` explicitly:

```swift
let html = Data("<html><body><p>Hello</p></body></html>".utf8)
guard let document = SwiftLibXML.XMLDocument(data: html, parser: htmlMemoryParser) else {
    return
}
```

## Text Nodes

libxml2 stores the whitespace between sibling elements as text nodes. When
you iterate ``XMLElement/children`` or ``XMLElement/descendants``, those text
nodes appear alongside element nodes and report the name `"text"`. This is
correct and expected libxml2 behaviour.

To work only with named elements, filter by name:

```swift
for child in root.children where child.name != "text" {
    print(child.name)
}
```

Alternatively, an XPath expression such as `"//book"` already selects
element nodes exclusively and requires no filtering.

## Work from the Root Element

``XMLDocument/rootElement`` gives you the root node as an ``XMLElement``. From
there you can inspect:

- ``XMLElement/name``
- ``XMLElement/content``
- ``XMLElement/attributes``
- ``XMLElement/children``
- ``XMLElement/descendants``
- ``XMLElement/namespaces``

## Choose a Traversal Strategy

``XMLElement`` conforms to `Sequence`, so iterating over an element performs a
depth-first pre-order walk using ``XMLElement/Iterator``. When you only need
the current level, use ``XMLElement/levelIterator()`` or
``XMLElement/siblings``.

``XMLDocument`` is itself a `Sequence` whose iterator visits every node in the
document in depth-first pre-order, including text nodes:

```swift
for node in document {
    // visits every node, including whitespace text nodes
    print("\(node.name): \(node.content.prefix(40))")
}
```

``XMLDocument/tree`` exposes ``XMLTree``, which yields tuples containing the
nesting level, the current node, and its parent. That is useful when you need
to render or analyse indentation-sensitive output without recomputing ancestry:

```swift
for (level, node, _) in document.tree {
    let indent = String(repeating: "  ", count: level)
    print("\(indent)\(node.name)")
}
```

## Read Attributes

Use ``XMLElement/attribute(named:)`` to read an attribute value by name:

```swift
let id = element.attribute(named: "id") ?? "none"
```

Use ``XMLElement/attribute(named:namespace:)`` when the attribute carries a
namespace URI:

```swift
let lang = element.attribute(named: "lang", namespace: "http://www.w3.org/XML/1998/namespace")
```

Iterate all attributes via ``XMLElement/attributes``:

```swift
for attribute in element.attributes {
    print("\(attribute.name)")
}
```
