//
//  XMLPath.swift
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
/// A wrapper around libxml2 xmlXPathTypePtr
///
public struct XMLPath {
    /// The underlying XPath pointer
    @usableFromInline let xpath: xmlXPathObjectPtr

    /// Default initialiser
    /// - Parameter xpath: The underlying XPath pointer to wrap
    @usableFromInline init(xpath: xmlXPathObjectPtr) {
        self.xpath = xpath
    }
}

///
/// Extension to make XMLPath behave like an array
///
extension XMLPath: RandomAccessCollection {
    @usableFromInline var nodeSet: xmlNodeSetPtr? { xpath.pointee.nodesetval }
    @inlinable public var startIndex: Int { 0 }
    @inlinable public var endIndex: Int { nodeSet.map { Int($0.pointee.nodeNr) } ?? 0 }

    @inlinable public subscript(_ i: Int) -> XMLElement {
        precondition(i >= startIndex)
        precondition(i < endIndex)
        return XMLElement(node: nodeSet!.pointee.nodeTab![i]!)
    }
}

extension XMLDocument {
    /// Compile a given XPath for queries
    /// - Parameters:
    ///   - path: The XPath to compile
    ///   - namespaces: A sequence of namespaces to use
    ///   - defaultPrefix: The default namespace prefix to use
    /// - Returns: A compiled `XMLPath` or `nil` if unsuccessful
    @inlinable public func xpath(_ path: String, namespaces ns: AnySequence<XMLNameSpace> = emptySequence(), defaultPrefix: String = "ns") -> XMLPath? {
        guard let context = xmlXPathNewContext(xml) else { return nil }
        defer { xmlXPathFreeContext(context) }
        ns.forEach { xmlXPathRegisterNs(context, $0.prefix ?? defaultPrefix, $0.href ?? "") }
        return xpath(path, context: context)
    }

    /// Compile a given XPath for queries
    /// - Parameters:
    ///   - path: The XPath to compile
    ///   - namespaces: An array of tuples containin `prefix` and `href`
    /// - Returns: A compiled `XMLPath` or `nil` if unsuccessful
    @inlinable public func xpath(_ path: String, namespaces ns: [(prefix: String, href: String)]) -> XMLPath? {
        guard let context = xmlXPathNewContext(xml) else { return nil }
        defer { xmlXPathFreeContext(context) }
        ns.forEach { xmlXPathRegisterNs(context, $0.prefix, $0.href) }
        return xpath(path, context: context)
    }

    /// Compile an xpath for queries with a given context
    /// - Parameters:
    ///   - path: The XPath to compile
    ///   - context: A pointer to the XML path context to use
    /// - Returns: A compiled `XMLPath` or `nil` if unsuccessful
    @inlinable public func xpath(_ path: String, context: xmlXPathContextPtr) -> XMLPath? {
        guard let xmlXPath = xmlXPathEvalExpression(path, context) else { return nil }
        return XMLPath(xpath: xmlXPath)
    }
}

