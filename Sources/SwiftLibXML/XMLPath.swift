//
//  XMLPath.swift
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

/// A collection wrapper around a libxml2 XPath result.
public struct XMLPath {
    /// The underlying libxml2 XPath result pointer.
    ///
    /// This remains internal so callers can work with `XMLElement` values
    /// rather than managing `xmlXPathObjectPtr` directly.
    @usableFromInline let xpath: xmlXPathObjectPtr

    /// Creates a wrapper around an existing XPath result pointer.
    ///
    /// - Parameter xpath: The XPath result pointer to wrap.
    @usableFromInline init(xpath: xmlXPathObjectPtr) {
        self.xpath = xpath
    }
}

/// Treats an XPath result set as a random-access collection of elements.
extension XMLPath: RandomAccessCollection {
    /// The underlying libxml2 node set, if the XPath result contains one.
    @usableFromInline var nodeSet: xmlNodeSetPtr? { xpath.pointee.nodesetval }

    /// The index of the first element in the result set.
    @inlinable public var startIndex: Int { 0 }

    /// The index one past the last element in the result set.
    @inlinable public var endIndex: Int { nodeSet.map { Int($0.pointee.nodeNr) } ?? 0 }

    /// Returns the element at the requested result index.
    ///
    /// - Parameter i: The zero-based position to read.
    /// - Returns: The matching XML element.
    @inlinable public subscript(_ i: Int) -> XMLElement {
        precondition(i >= startIndex)
        precondition(i < endIndex)
        return XMLElement(node: nodeSet!.pointee.nodeTab![i]!)
    }
}

extension XMLDocument {
    /// Compiles an XPath expression using namespace declarations from the document.
    ///
    /// Supply namespaces taken from the parsed tree when the expression refers
    /// to prefixed or default namespaces. A fallback prefix is registered for
    /// namespace declarations that do not carry an explicit prefix.
    ///
    /// - Parameters:
    ///   - path: The XPath expression to compile.
    ///   - ns: The namespace declarations to register in the XPath context.
    ///   - defaultPrefix: The prefix to use for default namespace declarations.
    /// - Returns: A compiled XPath result, or `nil` when context creation or evaluation fails.
    @inlinable public func xpath(_ path: String, namespaces ns: AnySequence<XMLNameSpace> = emptySequence(), defaultPrefix: String = "ns") -> XMLPath? {
        guard let context = xmlXPathNewContext(xml) else { return nil }
        defer { xmlXPathFreeContext(context) }
        ns.forEach { xmlXPathRegisterNs(context, $0.prefix ?? defaultPrefix, $0.href ?? "") }
        return xpath(path, context: context)
    }

    /// Compiles an XPath expression using explicit namespace registrations.
    ///
    /// This overload is convenient when namespace prefixes are known in
    /// advance and do not need to be read from the document.
    ///
    /// - Parameters:
    ///   - path: The XPath expression to compile.
    ///   - ns: Namespace registrations as `(prefix, href)` tuples.
    /// - Returns: A compiled XPath result, or `nil` when context creation or evaluation fails.
    @inlinable public func xpath(_ path: String, namespaces ns: [(prefix: String, href: String)]) -> XMLPath? {
        guard let context = xmlXPathNewContext(xml) else { return nil }
        defer { xmlXPathFreeContext(context) }
        ns.forEach { xmlXPathRegisterNs(context, $0.prefix, $0.href) }
        return xpath(path, context: context)
    }

    /// Evaluates an XPath expression in an existing libxml2 XPath context.
    ///
    /// Use this overload when you need full control over the prepared context,
    /// such as custom variable registration performed outside SwiftLibXML.
    ///
    /// - Parameters:
    ///   - path: The XPath expression to compile.
    ///   - context: The XPath context to evaluate the expression in.
    /// - Returns: A compiled XPath result, or `nil` if evaluation fails.
    @inlinable public func xpath(_ path: String, context: xmlXPathContextPtr) -> XMLPath? {
        guard let xmlXPath = xmlXPathEvalExpression(path, context) else { return nil }
        return XMLPath(xpath: xmlXPath)
    }
}
