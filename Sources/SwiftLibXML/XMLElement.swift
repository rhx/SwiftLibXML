//
//  XMLElement.swift
//  SwiftLibXML
//
//  Created by Rene Hexel on 24/03/2016.
//  Copyright © 2016, 2018, 2020, 2021 Rene Hexel. All rights reserved.
//
#if !canImport(Darwin)
    import CLibXML2
#else
    import Darwin
    import libxml2
#endif

/// A Swift wrapper around a libxml2 element node.
public struct XMLElement {
    /// The underlying libxml2 node pointer.
    ///
    /// This stored pointer remains internal so the public API can stay focused
    /// on traversal and value access.
    @usableFromInline let node: xmlNodePtr

    /// Creates a wrapper around an existing libxml2 node pointer.
    ///
    /// - Parameter node: The element node to wrap.
    @usableFromInline init(node: xmlNodePtr) {
        self.node = node
    }
}

extension XMLElement {
    /// The local name of the element.
    @inlinable public var name: String {
        let name: UnsafePointer<xmlChar>? = node.pointee.name
        return name.map { String(cString: UnsafePointer($0)) } ?? ""
    }

    /// The concatenated textual content of the element subtree.
    @inlinable public var content: String {
        let content: UnsafeMutablePointer<xmlChar>? = xmlNodeGetContent(node)
        let txt = content.map { String(cString: UnsafePointer<xmlChar>($0)) } ?? ""
        xmlFree(content)
        return txt
    }

    /// The attributes declared directly on the element.
    @inlinable public var attributes: AnySequence<XMLAttribute> {
        guard node.pointee.properties != nil else { return emptySequence() }
        return AnySequence { XMLAttribute(attr: self.node.pointee.properties).makeIterator() }
    }

    /// The immediate parent element.
    @inlinable public var parent: XMLElement {
        return XMLElement(node: node.pointee.parent)
    }

    /// The following siblings of the element on the same level.
    @inlinable public var siblings: AnySequence<XMLElement> {
        guard node.pointee.next != nil else { return emptySequence() }
        return AnySequence { XMLElement(node: self.node.pointee.next).levelIterator() }
    }

    /// The immediate child elements of the element.
    @inlinable public var children: AnySequence<XMLElement> {
        guard node.pointee.children != nil else { return emptySequence() }
        return AnySequence { XMLElement(node: self.node.pointee.children).levelIterator() }
    }

    /// The descendant elements in depth-first pre-order.
    @inlinable public var descendants: AnySequence<XMLElement> {
        guard node.pointee.children != nil else { return emptySequence() }
        return AnySequence { XMLElement(node: self.node.pointee.children).makeIterator() }
    }

    /// Returns the string value of a named attribute.
    ///
    /// - Parameters:
    ///   - n: The local attribute name to look up.
    /// - Returns: The attribute value, or `nil` if no matching attribute exists.
    @inlinable public func attribute(named n: String) -> String? {
        let value: UnsafeMutablePointer<xmlChar>? = xmlGetProp(node, n)
        return value.map { String(cString: UnsafePointer<xmlChar>($0)) }
    }

    /// Returns the string value of a namespace-qualified attribute.
    ///
    /// - Parameters:
    ///   - name: The local attribute name to look up.
    ///   - namespace: The namespace URI used to qualify the attribute.
    /// - Returns: The attribute value, or `nil` if no matching attribute exists.
    @inlinable public func attribute(named name: String, namespace: String) -> String? {
        let value: UnsafeMutablePointer<xmlChar>? = xmlGetNsProp(node, name, namespace)
        return value.map { String(cString: UnsafePointer<xmlChar>($0)) }
    }

    /// Returns a Boolean interpretation of a named attribute.
    ///
    /// The attribute is treated as `true` only when it exists and can be parsed
    /// as a non-zero integer.
    ///
    /// - Parameters:
    ///   - n: The local attribute name to look up.
    /// - Returns: `true` when the attribute exists and contains a non-zero integer.
    @inlinable public func bool(named n: String) -> Bool {
        if let str = attribute(named: n),
           let val = Int(str), val != 0 {
            return true
        } else {
            return false
        }
    }

    /// Returns a Boolean interpretation of a namespace-qualified attribute.
    ///
    /// - Parameters:
    ///   - n: The local attribute name to look up.
    ///   - namespace: The namespace URI used to qualify the attribute.
    /// - Returns: `true` when the attribute exists and contains a non-zero integer.
    @inlinable public func bool(named n: String, namespace: String) -> Bool {
        if let str = attribute(named: n, namespace:  namespace),
           let val = Int(str), val != 0 {
            return true
        } else {
            return false
        }
    }
}

//
// MARK: - Comparison
//
extension XMLElement: Equatable {
    /// Returns `true` when two wrappers point to the same libxml2 node.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand element.
    ///   - rhs: The right-hand element.
    /// - Returns: `true` when both wrappers reference the same node pointer.
    @inlinable public static func===(_ lhs: XMLElement, _ rhs: XMLElement) -> Bool { lhs.node == rhs.node }

    /// Compares two elements by identity, then by namespace definition and name.
    ///
    /// This comparison does not walk the subtree or inspect attribute values.
    /// It is a lightweight equivalence check based on the libxml2 node pointer
    /// or matching namespace definition and local name.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand element.
    ///   - rhs: The right-hand element.
    /// - Returns: `true` when the elements represent the same node or equivalent name/namespace pairs.
    @inlinable public static func==(_ lhs: XMLElement, _ rhs: XMLElement) -> Bool {
        lhs.node == rhs.node ||
        (lhs.node.pointee.nsDef == rhs.node.pointee.nsDef &&
         lhs.name == rhs.name)
    }
}

extension XMLElement: Comparable {
    /// The concatenated namespace prefixes declared for the element.
    @inlinable public var namespace: String {
        namespaces.reduce("") { $0 + ($1.prefix ?? "") }
    }

    /// The namespace-qualified element name.
    @inlinable public var qualifiedName: String {
        namespace + name
    }

    /// Orders elements lexicographically by qualified name when they are distinct nodes.
    ///
    /// This comparison does not walk the subtree or inspect attribute values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand element.
    ///   - rhs: The right-hand element.
    /// - Returns: `true` when `lhs` and `rhs` are different nodes and `lhs` sorts before `rhs`.
    @inlinable public static func < (lhs: XMLElement, rhs: XMLElement) -> Bool {
        lhs.node != rhs.node &&
        lhs.qualifiedName < rhs.qualifiedName
    }
}

//
// MARK: - Conversion to String
//
extension XMLElement: CustomStringConvertible {
    /// The qualified element name.
    @inlinable public var description: String { return qualifiedName }
}

extension XMLElement: CustomDebugStringConvertible {
    /// A debug string containing the qualified name and libxml2 node type.
    @inlinable public var debugDescription: String {
        return "\(qualifiedName): \(node.pointee.type)"
    }
}

//
// MARK: - Enumerating XML Elements
//
extension XMLElement: Sequence {
    /// Returns a depth-first pre-order iterator rooted at the element.
    public func makeIterator() -> XMLElement.Iterator {
        return Iterator(root: self)
    }

    /// Returns an iterator across the current level only.
    public func levelIterator() -> XMLElement.LevelIterator {
        return LevelIterator(root: self)
    }
}


public extension XMLElement {
    /// Iterates over an element subtree in depth-first pre-order.
    class Iterator: IteratorProtocol {
        /// The element queued to be returned next.
        @usableFromInline var element: XMLElement?

        /// The child iterator currently being drained, if any.
        @usableFromInline var child: Iterator?

        /// Creates an iterator rooted at the supplied element.
        ///
        /// - Parameter root: The first element to return.
        @usableFromInline init(root: XMLElement) {
            element = root
        }

        /// Returns the next element in depth-first pre-order.
        @inlinable public func next() -> XMLElement? {
            if let c = child {
                if let element = c.next() { return element }         // children
                let sibling = element?.node.pointee.next
                element = sibling.map { XMLElement(node: $0 ) }
            } else if let children = element?.node.pointee.children {
                child = XMLElement(node: children).makeIterator()
            } else {
                let currentElement = element
                let sibling = element?.node.pointee.next
                element = sibling.map { XMLElement(node: $0 ) }
                return currentElement
            }
            return element
        }
    }

    /// Iterates across a single sibling chain without descending into children.
    class LevelIterator: IteratorProtocol {
        /// The element queued to be returned next.
        var element: XMLElement?

        /// Creates an iterator rooted at the supplied element.
        ///
        /// - Parameter root: The first sibling to return.
        init(root: XMLElement) {
            element = root
        }

        /// Returns the next sibling on the same level.
        public func next() -> XMLElement? {
            let e = element
            let sibling = e?.node.pointee.next
            element = sibling.map(XMLElement.init)
            return e
        }
    }
}


//
// MARK: - Namespaces
//
extension XMLElement {
    /// The namespace declarations attached directly to the element.
    public var namespaces: AnySequence<XMLNameSpace> {
        guard node.pointee.nsDef != nil else { return emptySequence() }
        return AnySequence { XMLNameSpace(ns: self.node.pointee.nsDef).makeIterator() }
    }
}
