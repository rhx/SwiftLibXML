//
//  XMLNameSpace.swift
//  SwiftLibXML
//
//  Created by Rene Hexel on 25/03/2016.
//  Copyright © 2016, 2018, 2020, 2021 Rene Hexel. All rights reserved.
//
#if !canImport(Darwin)
    import CLibXML2
#else
    import Darwin
    import libxml2
#endif

/// A Swift wrapper around a libxml2 namespace definition.
public struct XMLNameSpace {
    /// The underlying libxml2 namespace pointer.
    ///
    /// This remains an implementation detail so the public API can expose
    /// strings and sequences instead of raw C pointers.
    @usableFromInline let ns: xmlNsPtr

    /// Creates a wrapper around an existing libxml2 namespace pointer.
    ///
    /// - Parameter ns: The namespace pointer to wrap.
    @usableFromInline init(ns: xmlNsPtr) {
        self.ns = ns
    }
}

extension XMLNameSpace {
    /// The declared prefix for the namespace.
    ///
    /// This is `nil` for a default namespace declaration.
    @inlinable public var prefix: String? {
        let prefix: UnsafePointer<xmlChar>? = ns.pointee.prefix
        return prefix.map { String(cString: UnsafePointer($0)) }
    }

    /// The namespace URI referenced by the declaration.
    @inlinable public var href: String? {
        let href: UnsafePointer<xmlChar>? = ns.pointee.href
        return href.map { String(cString: UnsafePointer($0)) }
    }
}


//
// MARK: - Enumerating XML namespaces
//
extension XMLNameSpace: Sequence {
    /// Returns an iterator over this namespace declaration and its siblings.
    @inlinable public func makeIterator() -> XMLNameSpace.Iterator {
        return Iterator(root: self)
    }
}


extension XMLNameSpace {
    /// Iterates across namespace declarations linked from the same element.
    public class Iterator: IteratorProtocol {
        /// The namespace currently queued to be returned.
        @usableFromInline var current: XMLNameSpace?

        /// Creates an iterator rooted at the supplied namespace.
        ///
        /// - Parameter root: The first namespace to return.
        @usableFromInline init(root: XMLNameSpace) {
            current = root
        }

        /// Returns the next namespace in the sibling chain.
        ///
        /// The iterator advances through libxml2's `next` links without
        /// recursing because namespace declarations are stored as a flat list.
        @inlinable public func next() -> XMLNameSpace? {
            let c = current
            let sibling = c?.ns.pointee.next
            current = sibling.map(XMLNameSpace.init)
            return c
        }
    }
}
