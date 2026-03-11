//
//  XMLDocument.swift
//  SwiftLibXML
//
//  Created by Rene Hexel on 24/03/2016.
//  Copyright © 2016, 2018, 2020, 2021 Rene Hexel. All rights reserved.
//
import Foundation
#if !canImport(Darwin)
    import CLibXML2
#else
    import libxml2
#endif

/// In-memory XML parser.
///
/// Wraps `xmlReadMemory` with a stable `Int32` options type across all
/// platforms.  libxml2 2.12 changed the `options` parameter from `int` to
/// `unsigned int`; `numericCast` bridges the two safely for the positive-only
/// flag values that XML parser options use.
public let xmlMemoryParser: (UnsafePointer<CChar>?, Int32, UnsafePointer<CChar>?, UnsafePointer<CChar>?, Int32) -> xmlDocPtr? = {
    xmlReadMemory($0, $1, $2, $3, numericCast($4))
}

/// In-memory HTML parser.
///
/// Wraps `htmlReadMemory` with a stable `Int32` options type across all
/// platforms.  See ``xmlMemoryParser`` for details.
public let htmlMemoryParser: (UnsafePointer<CChar>?, Int32, UnsafePointer<CChar>?, UnsafePointer<CChar>?, Int32) -> htmlDocPtr? = {
    htmlReadMemory($0, $1, $2, $3, numericCast($4))
}

/// A Swift wrapper around a libxml2 document.
public class XMLDocument {
    /// Parser option flags understood by libxml2.
    public typealias ParserOptions = xmlParserOption

    /// The underlying libxml2 document pointer.
    ///
    /// This remains an implementation detail so callers can work with Swift
    /// wrappers while the package keeps ownership of document lifetime.
    @usableFromInline let xml: xmlDocPtr
//    let ctx: xmlParserCtxtPtr? = nil

    /// Wraps an existing libxml2 document pointer.
    ///
    /// This initialiser is mainly used internally after parsing has already
    /// succeeded.
    ///
    /// - Parameter xmlDocument: The document pointer to wrap.
    @inlinable public init(xmlDocument: xmlDocPtr) {
        xml = xmlDocument
        xmlInitParser()
    }

    /// Parses a document from in-memory data.
    ///
    /// The default options suppress warning output, disable network access, and
    /// ask libxml2 to recover where possible.
    ///
    /// - Parameters:
    ///   - data: The XML or HTML data to parse.
    ///   - options: The libxml2 parser options to apply.
    ///   - parse: The parse function to call. Defaults to ``xmlMemoryParser``.
    /// - Returns: A document wrapper, or `nil` if parsing fails.
    @inlinable public convenience init?(data: Data, options: ParserOptions = [.noWarning, .noError, .recover, .noNet], parser parse: (UnsafePointer<CChar>?, Int32, UnsafePointer<CChar>?, UnsafePointer<CChar>?, Int32) -> xmlDocPtr? = xmlMemoryParser) {
        guard let xml = data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> xmlDocPtr? in
            guard let base = buffer.baseAddress?.assumingMemoryBound(to: CChar.self) else { return nil }
            return parse(base, Int32(buffer.count), "", nil, Int32(truncatingIfNeeded: options.rawValue))
        }) else { return nil }
        self.init(xmlDocument: xml)
    }

    /// Parses a document from an in-memory character buffer.
    ///
    /// - Parameters:
    ///   - buffer: The character buffer containing the XML or HTML source.
    ///   - options: The libxml2 parser options to apply.
    ///   - parse: The parse function to call. Defaults to ``xmlMemoryParser``.
    /// - Returns: A document wrapper, or `nil` if parsing fails.
    @inlinable public convenience init?(buffer: UnsafeBufferPointer<CChar>, options: ParserOptions = [.noWarning, .noError, .recover, .noNet], parser parse: (UnsafePointer<CChar>?, Int32, UnsafePointer<CChar>?, UnsafePointer<CChar>?, Int32) -> xmlDocPtr? = xmlMemoryParser) {
        guard let base = buffer.baseAddress,
              let xml = parse(base, Int32(buffer.count), "", nil, Int32(truncatingIfNeeded: options.rawValue)) else { return nil }
        self.init(xmlDocument: xml)
    }

    /// Parses a document from a file on disk.
    ///
    /// - Parameter fileName: The null-terminated file path to read.
    /// - Returns: A document wrapper, or `nil` if parsing fails.
    @inlinable public convenience init?(fromFile fileName: UnsafePointer<CChar>) {
        guard let xml = xmlParseFile(fileName) else { return nil }
        self.init(xmlDocument: xml)
    }

    /// Releases the underlying libxml2 document.
    deinit {
        xmlFreeDoc(xml)
//        if let ctx = ctx { xmlFreeParserCtxt(ctx) }
    }

    /// The root element of the parsed document tree.
    public var rootElement: XMLElement {
        return XMLElement(node: xmlDocGetRootElement(xml))
    }

    /// A tree view that yields each node together with its level and parent.
    public var tree: XMLTree {
        return XMLTree(xml: self)
    }

    /// Resolves the string value stored in a libxml2 attribute node.
    ///
    /// Use this when you already have an ``XMLAttribute`` value and want the
    /// attribute content as a Swift string.
    ///
    /// - Parameter attribute: The attribute whose value should be read.
    /// - Returns: The attribute value, or `nil` when the attribute has no string content.
    public func valueFor(attribute: XMLAttribute) -> String? {
        let attr = attribute.attr
        guard let children = attr.pointee.children,
              let s = xmlNodeListGetString(xml, children, 1) else { return nil }
        let value = String(cString: UnsafePointer<xmlChar>(s))
        xmlFree(s)
        return value
    }

    /// Resolves the value of a named attribute on an element.
    ///
    /// This performs a linear scan across the element's attributes and returns
    /// the first matching name.
    ///
    /// - Parameters:
    ///   - name: The attribute name to look up.
    ///   - e: The element whose attributes should be searched.
    /// - Returns: The attribute value, or `nil` when no matching attribute exists.
    public func valueFor(attribute name: String, inElement e: XMLElement) -> String? {
        let attr = e.attributes.filter({$0.name == name}).first
        return attr.flatMap { valueFor(attribute: $0) }
    }
}

extension XMLDocument.ParserOptions: OptionSet {
    /// Recover on errors
    public static let recover = XML_PARSE_RECOVER
    /// Substitute entitites
    public static let noEntity = XML_PARSE_NOENT
    /// Load external subsets
    public static let loadExternalSubsets = XML_PARSE_DTDLOAD
    /// Default DTD attributes
    public static let defaultDTDAttributes = XML_PARSE_DTDATTR
    /// Validate with the DTD
    public static let validateDTD = XML_PARSE_DTDVALID
    /// Suppress error reports
    public static let noError = XML_PARSE_NOERROR
    /// Suppress warning reports
    public static let noWarning = XML_PARSE_NOWARNING
    /// Pedantic error reporting
    public static let pedantic = XML_PARSE_PEDANTIC
    /// Remove blank nodes
    public static let noBlanks = XML_PARSE_NOBLANKS
    /// Use the SAX1 interface internally
    public static let sa1 = XML_PARSE_SAX1
    /// Implement XInclude substitition
    public static let xInclude = XML_PARSE_XINCLUDE
    /// Forbid network access
    public static let noNet = XML_PARSE_NONET
    /// Do not reuse the context dictionary
    public static let noDictionary = XML_PARSE_NODICT
    /// Remove redundant namespaces declarations
    public static let nsClean = XML_PARSE_NSCLEAN
    /// Merge CDATA as text nodes
    public static let noCDATA = XML_PARSE_NOCDATA
    /// Do not generate XINCLUDE START/END nodes
    public static let noXIncludeNode = XML_PARSE_NOXINCNODE
    /// Compact small text nodes
    ///
    /// No modification of the tree is allowed afterwards
    /// (will possibly crash if you try to modify the tree)
    public static let compact = XML_PARSE_COMPACT
    /// Parse using XML-1.0 before update 5
    public static let old10 = XML_PARSE_OLD10
    /// Do not fixup XINCLUDE xml:base uris
    public static let noBaseFix = XML_PARSE_NOBASEFIX
    /// Relax any hardcoded limit from the parser
    public static let huge = XML_PARSE_HUGE
    /// Parse using SAX2 interface before update 5
    public static let oldSAX = XML_PARSE_OLDSAX
    /// Ignore internal document encoding hint
    public static let ignoreEncoding = XML_PARSE_IGNORE_ENC
    /// Store big line numbers in text PSVI field
    public static let bigLines = XML_PARSE_BIG_LINES
}

//
// MARK: - Enumerating XML
//
extension XMLDocument: Sequence {
    public typealias Iterator = XMLElement.Iterator

    /// Returns a depth-first iterator rooted at ``rootElement``.
    @inlinable public func makeIterator() -> Iterator {
        return Iterator(root: rootElement)
    }
}


/// Enumerates a document tree while preserving node depth and parentage.
public struct XMLTree: Sequence {
    /// A single tree entry containing the nesting level, node, and parent.
    public typealias Node = (level: Int, node: XMLElement, parent: XMLElement?)

    /// The document whose tree is being traversed.
    let document: XMLDocument

    /// Creates a tree view rooted at the supplied document.
    ///
    /// - Parameter xml: The document to traverse.
    public init(xml: XMLDocument) {
        document = xml
    }

    /// Iterates over the document in depth-first pre-order.
    public class Iterator: IteratorProtocol {
        /// The current depth within the traversal.
        let level: Int

        /// The parent element for nodes returned by this iterator.
        let parent: XMLElement?

        /// The element that will be returned next.
        var element: XMLElement?

        /// The child iterator currently being drained, if any.
        var child: Iterator?

        /// Creates an iterator rooted at a specific element.
        ///
        /// - Parameters:
        ///   - root: The first element to return.
        ///   - parent: The parent of `root`, if any.
        ///   - level: The nesting level for `root`.
        init(root: XMLElement, parent: XMLElement? = nil, level: Int = 0) {
            self.level = level
            self.parent = parent
            element = root
        }

        /// Returns the next element together with its level and parent.
        public func next() -> Node? {
            if let c = child {
                if let element = c.next() { return element }         // children
                let sibling = element?.node.pointee.next
                element = sibling.map { XMLElement(node: $0 ) }
            }
            let children = element?.node.pointee.children
            child = children.map { Iterator(root: XMLElement(node: $0), parent: element, level: level+1) }
            return element.map { (level, $0, parent) }
        }
    }

    /// Returns a depth-first iterator rooted at the document's root element.
    public func makeIterator() -> Iterator {
        return Iterator(root: document.rootElement)
    }
}
