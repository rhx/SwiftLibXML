//
//  EmptySequence.swift
//  SwiftLibXML
//
//  Created by Rene Hexel on 25/03/2016.
//  Copyright © 2016, 2019, 2021 Rene Hexel. All rights reserved.
//

/// Returns an iterator that never yields a value.
///
/// Use this helper when an API should return an iterator even though the
/// underlying libxml2 pointer chain is absent.
@inlinable public func emptyIterator<T>() -> AnyIterator<T> {
    return AnyIterator { nil }
}

/// Returns an empty sequence for the requested element type.
///
/// This keeps traversal properties cheap to consume without forcing callers to
/// special-case missing children, attributes, or namespaces.
@inlinable public func emptySequence<T>() -> AnySequence<T> {
    return AnySequence(EmptyCollection.Iterator())
}
