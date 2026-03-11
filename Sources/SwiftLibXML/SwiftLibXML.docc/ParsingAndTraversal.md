# Parsing and Traversal

Set up a document, read the root element, and walk the tree.

## Parse XML or HTML

Create an ``XMLDocument`` from `Data`, an in-memory `UnsafeBufferPointer`, or a
file path. The default parser uses ``xmlMemoryParser`` and parser options that
recover from minor errors while suppressing libxml2 warnings and network
access.

For HTML input, pass ``htmlMemoryParser`` explicitly:

```swift
import Foundation
import SwiftLibXML

let html = Data("<html><body><p>Hello</p></body></html>".utf8)
let document = XMLDocument(data: html, parser: htmlMemoryParser)
```

## Work from the Root Element

``XMLDocument/rootElement`` gives you the root node as an ``XMLElement``. From
there you can inspect:

- ``XMLElement/name``
- ``XMLElement/content``
- ``XMLElement/attributes``
- ``XMLElement/children``
- ``XMLElement/descendants``
- ``XMLElement/namespaces``

## Choose a Traversal Style

``XMLElement`` conforms to `Sequence`, so iterating over an element performs a
depth-first pre-order walk using ``XMLElement/Iterator``. When you only need
the current level, use ``XMLElement/levelIterator()`` or
``XMLElement/siblings``.

``XMLDocument/tree`` exposes ``XMLTree``, which yields tuples containing the
level, the current node, and its parent. That is useful when you need to render
or analyse indentation-sensitive output without recomputing ancestry.
