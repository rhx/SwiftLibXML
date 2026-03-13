# XPath Queries

Select matching elements with XPath expressions.

## Compile a Query

Use one of the `xpath` overloads on ``XMLDocument`` to compile an XPath
expression and receive an ``XMLPath`` collection. XPath selects element nodes
only, so there is no need to filter out text nodes:

```swift
if let titles = document.xpath("//title") {
    for title in titles {
        print(title.content)
    }
}
```

## Use Predicates

Standard XPath predicate syntax narrows results. Attribute predicates are
particularly useful:

```swift
// Select the book whose id attribute equals "2"
if let matches = document.xpath("//book[@id='2']") {
    for book in matches {
        print(book.attribute(named: "id") ?? "")
    }
}
```

## Treat Results as a Collection

``XMLPath`` conforms to `RandomAccessCollection`, so you can use familiar
collection operations — subscripting, iteration, `map`, `first`, `count` — without
converting the result set first:

```swift
if let books = document.xpath("//book") {
    print(books.count)           // number of results
    print(books[0].name)         // first result by index
    let titles = books.map { $0.children.first(where: { $0.name == "title" })?.content ?? "" }
}
```

## Register Namespaces

When an XPath expression uses namespace prefixes, register them before
evaluating. The overload that takes `[(prefix: String, href: String)]` tuples
is the most direct approach when the namespace URIs are known at compile time:

```swift
let ns: [(prefix: String, href: String)] = [
    ("atom", "http://www.w3.org/2005/Atom")
]
if let titles = document.xpath("//atom:title", namespaces: ns) {
    for title in titles {
        print(title.content)
    }
}
```

The overload that accepts an `AnySequence<XMLNameSpace>` is convenient when
the namespaces are read from the document itself:

```swift
let rootNS = document.rootElement.namespaces
if let titles = document.xpath("//atom:title", namespaces: rootNS) {
    for title in titles {
        print(title.content)
    }
}
```

See <doc:WorkingWithNamespaces> for a detailed treatment of namespace handling.
