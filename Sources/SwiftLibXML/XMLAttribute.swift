//
//  XMLAttribute.swift
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

/// A Swift wrapper around a libxml2 attribute node.
public struct XMLAttribute {
    /// The underlying libxml2 attribute pointer.
    ///
    /// This stored pointer stays internal so higher-level APIs can expose
    /// values and sequences instead of raw C state.
    @usableFromInline let attr: xmlAttrPtr

    /// Creates a wrapper around an existing libxml2 attribute pointer.
    ///
    /// - Parameter attr: The attribute pointer to wrap.
    @usableFromInline init(attr: xmlAttrPtr) {
        self.attr = attr
    }
}

extension XMLAttribute {
    /// The local name of the attribute.
    @inlinable public var name: String {
        guard let name = attr.pointee.name else { return "" }
        let description = String(cString: UnsafePointer(name))
        return description
    }

    /// The attribute value nodes attached to the attribute.
    ///
    /// libxml2 stores attribute values as linked nodes, so this returns a
    /// sequence rather than a single string.
    @inlinable public var children: AnySequence<XMLElement> {
        guard attr.pointee.children != nil else { return emptySequence() }
        return AnySequence { XMLElement(node: self.attr.pointee.children).makeIterator() }
    }
}


//
// MARK: - Conversion to String
//
extension XMLAttribute: CustomStringConvertible {
    /// A string representation of the attribute name.
    @inlinable public var description: String { return name }
}

extension XMLAttribute: CustomDebugStringConvertible {
    /// A debug representation containing the attribute name and libxml2 node type.
    @inlinable public var debugDescription: String {
        return "\(description): \(attr.pointee.type)"
    }
}

//
// MARK: - Enumerating XML Attributes
//
extension XMLAttribute: Sequence {
    /// Returns an iterator over this attribute and its sibling attributes.
    ///
    /// - Returns: An iterator rooted at the current attribute.
    @inlinable public func makeIterator() -> XMLAttribute.Iterator {
        return Iterator(root: self)
    }
}


extension XMLAttribute {
    /// Iterates across the linked list of sibling attributes.
    public class Iterator: IteratorProtocol {
        /// The attribute queued to be returned by the next call to `next()`.
        @usableFromInline var current: XMLAttribute?

        /// Creates an iterator rooted at the supplied attribute.
        ///
        /// - Parameter root: The first attribute to return.
        @usableFromInline init(root: XMLAttribute) {
            current = root
        }

        /// Returns the next attribute in the sibling chain.
        @inlinable public func next() -> XMLAttribute? {
            guard let c = current else { return nil }
            current = c.attr.pointee.next.map { XMLAttribute(attr: $0) }   // sibling
            return c
        }
    }
}
