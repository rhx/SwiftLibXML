//
//  XMLAttribute.swift
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
/// A wrapper around libxml2 xmlAttr
///
public struct XMLAttribute {
    /// The underlying XML attribute
    @usableFromInline let attr: xmlAttrPtr

    /// Defaiult initialiser
    /// - Parameter attr: The underlying XML attribute to wrap
    @usableFromInline init(attr: xmlAttrPtr) {
        self.attr = attr
    }
}

extension XMLAttribute {
    /// name of the XML attribute
    @inlinable public var name: String {
        guard let name = attr.pointee.name else { return "" }
        let description = String(cString: UnsafePointer(name))
        return description
    }

    /// children of the XML attribute
    @inlinable public var children: AnySequence<XMLElement> {
        guard attr.pointee.children != nil else { return emptySequence() }
        return AnySequence { XMLElement(node: self.attr.pointee.children).makeIterator() }
    }
}


//
// MARK: - Conversion to String
//
extension XMLAttribute: CustomStringConvertible {
    @inlinable public var description: String { return name }
}

extension XMLAttribute: CustomDebugStringConvertible {
    @inlinable public var debugDescription: String {
        return "\(description): \(attr.pointee.type)"
    }
}

//
// MARK: - Enumerating XML Attributes
//
extension XMLAttribute: Sequence {
    /// Create a sequence interator for the current attribute
    /// - Returns: An Iterator over the siblings of the current attribute
    @inlinable public func makeIterator() -> XMLAttribute.Iterator {
        return Iterator(root: self)
    }
}


extension XMLAttribute {
    public class Iterator: IteratorProtocol {
        /// The current attribute
        @usableFromInline var current: XMLAttribute?

        /// create a generator from a root element
        @usableFromInline init(root: XMLAttribute) {
            current = root
        }

        /// return the next element following a depth-first pre-order traversal
        @inlinable public func next() -> XMLAttribute? {
            guard let c = current else { return nil }
            current = c.attr.pointee.next.map { XMLAttribute(attr: $0) }   // sibling
            return c
        }
    }
}
