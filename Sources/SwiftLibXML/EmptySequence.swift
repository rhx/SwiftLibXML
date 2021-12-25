//
//  EmptySequence.swift
//  SwiftLibXML
//
//  Created by Rene Hexel on 25/03/2016.
//  Copyright © 2016, 2019, 2021 Rene Hexel. All rights reserved.
//

/// Function returning an iterator for an empty sequence of T
@inlinable public func emptyIterator<T>() -> AnyIterator<T> {
    return AnyIterator { nil }
}

/// Function returning an empty sequence of T
@inlinable public func emptySequence<T>() -> AnySequence<T> {
    return AnySequence(EmptyCollection.Iterator())
}
