//
//  XMLNameSpace.swift
//  SwiftLibXML
//
//  Created by Rene Hexel on 25/03/2016.
//  Copyright © 2016, 2018, 2020, 2021 Rene Hexel. All rights reserved.
//
#if os(Linux)
    import Glibc
    import CLibXML2
#else
    import Darwin
    import libxml2
#endif

///
/// XML Name space representation
///
public struct XMLNameSpace {
    /// The underlying XML namespace pointer
    @usableFromInline let ns: xmlNsPtr

    /// Default initialiser
    /// - Parameter ns: The underlying XML namespace to wrap
    @usableFromInline init(ns: xmlNsPtr) {
        self.ns = ns
    }
}

extension XMLNameSpace {
    /// prefix of the XML namespace
    @inlinable public var prefix: String? {
        let prefix: UnsafePointer<xmlChar>? = ns.pointee.prefix
        return prefix.map { String(cString: UnsafePointer($0)) }
    }

    /// href URI of the XML namespace
    @inlinable public var href: String? {
        let href: UnsafePointer<xmlChar>? = ns.pointee.href
        return href.map { String(cString: UnsafePointer($0)) }
    }
}


//
// MARK: - Enumerating XML namespaces
//
extension XMLNameSpace: Sequence {
    @inlinable public func makeIterator() -> XMLNameSpace.Iterator {
        return Iterator(root: self)
    }
}


extension XMLNameSpace {
    public class Iterator: IteratorProtocol {
        /// Pointer to the current namespace
        @usableFromInline var current: XMLNameSpace?

        /// create a generator from a root element
        @usableFromInline init(root: XMLNameSpace) {
            current = root
        }

        /// return the next element following a depth-first pre-order traversal
        @inlinable public func next() -> XMLNameSpace? {
            let c = current
            let sibling = c?.ns.pointee.next
            current = sibling.map(XMLNameSpace.init)
            return c
        }
    }
}
