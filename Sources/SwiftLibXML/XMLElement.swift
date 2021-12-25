//
//  XMLElement.swift
//  SwiftLibXML
//
//  Created by Rene Hexel on 24/03/2016.
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
/// A wrapper around libxml2 xmlElement
///
public struct XMLElement {
    /// The underlying node
    @usableFromInline let node: xmlNodePtr

    /// Default initialiser
    /// - Parameter node: The underlying XML node to wrap
    @usableFromInline init(node: xmlNodePtr) {
        self.node = node
    }
}

extension XMLElement {
    /// name of the XML element
    @inlinable public var name: String {
        let name: UnsafePointer<xmlChar>? = node.pointee.name
        return name.map { String(cString: UnsafePointer($0)) } ?? ""
    }

    /// content of the XML element
    @inlinable public var content: String {
        let content: UnsafeMutablePointer<xmlChar>? = xmlNodeGetContent(node)
        let txt = content.map { String(cString: UnsafePointer<xmlChar>($0)) } ?? ""
        xmlFree(content)
        return txt
    }

    /// attributes of the XML element
    @inlinable public var attributes: AnySequence<XMLAttribute> {
        guard node.pointee.properties != nil else { return emptySequence() }
        return AnySequence { XMLAttribute(attr: self.node.pointee.properties).makeIterator() }
    }

    /// parent of the XML element
    @inlinable public var parent: XMLElement {
        return XMLElement(node: node.pointee.parent)
    }

    /// siblings of the XML element
    @inlinable public var siblings: AnySequence<XMLElement> {
        guard node.pointee.next != nil else { return emptySequence() }
        return AnySequence { XMLElement(node: self.node.pointee.next).levelIterator() }
    }

    /// children of the XML element
    @inlinable public var children: AnySequence<XMLElement> {
        guard node.pointee.children != nil else { return emptySequence() }
        return AnySequence { XMLElement(node: self.node.pointee.children).levelIterator() }
    }

    /// recursive pre-order descendants of the XML element
    @inlinable public var descendants: AnySequence<XMLElement> {
        guard node.pointee.children != nil else { return emptySequence() }
        return AnySequence { XMLElement(node: self.node.pointee.children).makeIterator() }
    }

    /// return the value of a given attribute
    /// - Parameters:
    ///   - name: The name of the attribute to examine
    /// - Returns: The content of the attribute or `nil` if not found
    @inlinable public func attribute(named n: String) -> String? {
        let value: UnsafeMutablePointer<xmlChar>? = xmlGetProp(node, n)
        return value.map { String(cString: UnsafePointer<xmlChar>($0)) }
    }

    /// return the value of a given attribute in a given name space
    /// - Parameters:
    ///   - name: The name of the attribute to examine
    ///   - namespace: The namespace for the attribute
    /// - Returns: The content of the attribute or `nil` if not found
    @inlinable public func attribute(named name: String, namespace: String) -> String? {
        let value: UnsafeMutablePointer<xmlChar>? = xmlGetNsProp(node, name, namespace)
        return value.map { String(cString: UnsafePointer<xmlChar>($0)) }
    }

    /// return the boolean value of a given attribute
    /// - Parameters:
    ///   - name: The name of the attribute to examine
    /// - Returns: `true` if the attribute exists and has a non-zero value
    @inlinable public func bool(named n: String) -> Bool {
        if let str = attribute(named: n),
           let val = Int(str), val != 0 {
            return true
        } else {
            return false
        }
    }

    /// return the boolean value of a given attribute in a given name space
    /// - Parameters:
    ///   - name: The name of the attribute to examine
    ///   - namespace: The namespace for the attribute
    /// - Returns: `true` if the attribute exists and has a non-zero value
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
    /// Compare the node pointers of two XML elements
    /// and return `true` if both reference the same node
    /// - Parameters:
    ///   - lhs: The left hand side element
    ///   - rhs: The right hand side element
    /// - Returns: `true`if both XML elements reference the same node
    @inlinable public static func===(_ lhs: XMLElement, _ rhs: XMLElement) -> Bool { lhs.node == rhs.node }

    /// Compare the names of two XML elements
    /// and return `true` if both reference the same node
    /// or have the same name and are located within the
    /// same namespace.
    ///
    /// This function simply compares the namespaces and the names.
    /// It does not perform a full subtree walk on children and attributs.
    /// - Parameters:
    ///   - lhs: The left hand side element
    ///   - rhs: The right hand side element
    /// - Returns: `true`if both XML elements reference the same node
    @inlinable public static func==(_ lhs: XMLElement, _ rhs: XMLElement) -> Bool {
        lhs.node == rhs.node ||
        (lhs.node.pointee.nsDef == rhs.node.pointee.nsDef &&
         lhs.name == rhs.name)
    }
}

extension XMLElement: Comparable {
    /// Return the fully qualified namespaces in order
    @inlinable public var namespace: String {
        namespaces.reduce("") { $0 + ($1.prefix ?? "") }
    }
    /// Return the fully qualified name
    @inlinable public var qualifiedName: String {
        namespace + name
    }
    /// Compare the alphabetical order of the names of two XML elements
    /// and return `true` if both reference different nodes,
    /// and in a String comparison `lhs.name < rhs.name`
    ///
    /// This function simply compares the namespaces and the names.
    /// It does not perform a full subtree walk on children and attributs.
    /// - Parameters:
    ///   - lhs: The left hand side element
    ///   - rhs: The right hand side element
    /// - Returns: `true`if both XML elements reference the same node
    @inlinable public static func < (lhs: XMLElement, rhs: XMLElement) -> Bool {
        lhs.node != rhs.node &&
        lhs.qualifiedName < rhs.qualifiedName
    }
}

//
// MARK: - Conversion to String
//
extension XMLElement: CustomStringConvertible {
    /// A description of the XML element
    @inlinable public var description: String { return qualifiedName }
}

extension XMLElement: CustomDebugStringConvertible {
    /// The debug description of the element
    @inlinable public var debugDescription: String {
        return "\(qualifiedName): \(node.pointee.type)"
    }
}

//
// MARK: - Enumerating XML Elements
//
extension XMLElement: Sequence {
    /// return a recursive, depth-first, pre-order traversal generator
    public func makeIterator() -> XMLElement.Iterator {
        return Iterator(root: self)
    }

    /// return a one-level (breadth-only) generator
    public func levelIterator() -> XMLElement.LevelIterator {
        return LevelIterator(root: self)
    }
}


public extension XMLElement {
    /// Iterator for depth-first, pre-order enumeration
    class Iterator: IteratorProtocol {
        @usableFromInline var element: XMLElement?
        @usableFromInline var child: Iterator?

        /// create a generator from a root element
        @usableFromInline init(root: XMLElement) {
            element = root
        }

        /// return the next element following a depth-first pre-order traversal
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

    /// Flat generator for horizontally traversing one level of the tree
    class LevelIterator: IteratorProtocol {
        var element: XMLElement?

        /// create a sibling generator from a root element
        init(root: XMLElement) {
            element = root
        }

        /// return the next element following the list of siblings
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
    /// name spaces of the XML element
    public var namespaces: AnySequence<XMLNameSpace> {
        guard node.pointee.nsDef != nil else { return emptySequence() }
        return AnySequence { XMLNameSpace(ns: self.node.pointee.nsDef).makeIterator() }
    }
}
