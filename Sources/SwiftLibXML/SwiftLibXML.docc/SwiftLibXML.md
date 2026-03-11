# ``SwiftLibXML``

Parse and query XML and HTML documents with a small Swift wrapper around libxml2.

## Overview

SwiftLibXML wraps libxml2 document, element, attribute, namespace, and XPath
handles in Swift types that are easy to traverse and compare. The package keeps
libxml2 close to the surface, while still offering Swift-friendly iteration and
lookup APIs.

Use ``XMLDocument`` to parse data or a file, read the
``XMLDocument/rootElement``, and then walk the tree with ``XMLElement`` and
``XMLTree``. Namespace-aware XPath queries are available through
``XMLDocument/xpath(_:namespaces:defaultPrefix:)`` and
``XMLDocument/xpath(_:namespaces:)``.

## Topics

### Essentials

- <doc:ParsingAndTraversal>
- <doc:XPathQueries>
- <doc:ImplementationNotes>

### Parsing Documents

- ``XMLDocument``
- ``xmlMemoryParser``
- ``htmlMemoryParser``

### Traversing Trees

- ``XMLElement``
- ``XMLTree``
- ``XMLAttribute``
- ``XMLNameSpace``

### Querying

- ``XMLPath``

### Supporting Helpers

- ``emptyIterator()``
- ``emptySequence()``
