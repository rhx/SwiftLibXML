# Implementation Notes

Notes about the lower-level wrappers that back the public API.

## Underlying libxml2 Handles

The package stores libxml2 pointers directly inside the wrapper types:

- `XMLDocument` keeps an `xmlDocPtr`.
- `XMLElement` keeps an `xmlNodePtr`.
- `XMLAttribute` keeps an `xmlAttrPtr`.
- `XMLNameSpace` keeps an `xmlNsPtr`.
- `XMLPath` keeps an `xmlXPathObjectPtr`.

These stored properties are intentionally kept as implementation details so the
public API can stay small while still mapping closely to libxml2 behaviour.

## Internal Iteration State

The iterator types for ``XMLElement``, ``XMLAttribute``, ``XMLNameSpace``, and
``XMLTree`` keep internal cursor state that mirrors libxml2 sibling and child
links. Their implementation is documented in source so that future maintenance
can stay aligned with the traversal order relied on by the test suite.

## Empty Sequences

``emptyIterator()`` and ``emptySequence()`` are small helpers used throughout
the package to avoid special-case collection code when libxml2 pointers are
missing. They make properties such as ``XMLElement/children`` and
``XMLElement/attributes`` cheap to consume even when a node has no related
values.
