# XPath Queries

Select matching elements with XPath expressions.

## Compile a Query

Use one of the `xpath` overloads on ``XMLDocument`` to compile an XPath
expression and receive an ``XMLPath`` collection.

```swift
if let titles = document.xpath("//title") {
    for title in titles {
        print(title.content)
    }
}
```

## Register Namespaces

When an expression needs namespace prefixes, either pass a sequence of
``XMLNameSpace`` values or an array of `(prefix, href)` tuples. The overload
that accepts ``XMLNameSpace`` values also lets you supply a fallback prefix for
default namespaces.

## Treat Results as a Collection

``XMLPath`` conforms to `RandomAccessCollection`, so you can use familiar
collection operations such as indexing, iteration, `map`, and `first` without
converting the result set first.
