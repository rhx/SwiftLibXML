# Working with Namespaces

Query namespace-prefixed elements and attributes using XPath.

## What Are XML Namespaces?

An XML namespace associates element and attribute names with a URI, preventing
name collisions between vocabularies. A document can mix multiple vocabularies
by declaring namespace prefixes:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns:atom="http://www.w3.org/2005/Atom">
  <atom:entry>
    <atom:title>SwiftLibXML 2.0 Released</atom:title>
    <atom:updated>2026-01-15T00:00:00Z</atom:updated>
  </atom:entry>
</feed>
```

Here `atom` is a prefix bound to `http://www.w3.org/2005/Atom`. Any element
or attribute carrying that prefix belongs to the Atom namespace.

## Register Namespaces Explicitly

When you know the namespace URIs at compile time, pass a
`[(prefix: String, href: String)]` array to the XPath overload:

```swift
import Foundation
import SwiftLibXML

let xml = """
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns:atom="http://www.w3.org/2005/Atom">
  <atom:entry>
    <atom:title>SwiftLibXML 2.0 Released</atom:title>
    <atom:updated>2026-01-15T00:00:00Z</atom:updated>
  </atom:entry>
</feed>
"""

guard let document = SwiftLibXML.XMLDocument(data: Data(xml.utf8)) else { return }

let ns: [(prefix: String, href: String)] = [
    ("atom", "http://www.w3.org/2005/Atom")
]
if let titles = document.xpath("//atom:title", namespaces: ns) {
    for title in titles {
        print(title.content)   // SwiftLibXML 2.0 Released
    }
}
```

## Use the Document's Own Namespace Declarations

When the namespace declarations are only known at runtime, read them from the
document via ``XMLElement/namespaces`` and pass the resulting
`AnySequence<XMLNameSpace>` directly:

```swift
let rootNS = document.rootElement.namespaces
if let titles = document.xpath("//atom:title", namespaces: rootNS) {
    for title in titles {
        print(title.content)
    }
}
```

## Default Namespaces

A document may declare a default namespace without a prefix:

```xml
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <title>SwiftLibXML 2.0 Released</title>
  </entry>
</feed>
```

XPath has no concept of a default namespace: every name in an XPath expression
must carry an explicit prefix, even if the document uses a default namespace.
Supply a prefix via the `defaultPrefix` parameter and use it in your
expression:

```swift
let ns = document.rootElement.namespaces
if let titles = document.xpath("//ns:title", namespaces: ns, defaultPrefix: "ns") {
    for title in titles {
        print(title.content)
    }
}
```

## Iterate Namespace Declarations

``XMLElement/namespaces`` returns the namespace declarations attached to a
specific element. Each ``XMLNameSpace`` value exposes the
``XMLNameSpace/prefix`` (which is `nil` for a default namespace declaration)
and the ``XMLNameSpace/href``:

```swift
for ns in document.rootElement.namespaces {
    print("\(ns.prefix ?? "(default)") → \(ns.href ?? "")")
}
// atom → http://www.w3.org/2005/Atom
```
