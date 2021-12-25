//
//  XMLDocument.swift
//  SwiftLibXML
//
//  Created by Rene Hexel on 24/03/2016.
//  Copyright © 2016, 2018, 2020, 2021 Rene Hexel. All rights reserved.
//
import Foundation
#if os(Linux)
    import CLibXML2
#else
    import libxml2
#endif

///
/// A wrapper around libxml2 xmlDoc
///
public class XMLDocument {
    public typealias ParserOptions = xmlParserOption
    /// The underlying XML document
    @usableFromInline let xml: xmlDocPtr
//    let ctx: xmlParserCtxtPtr? = nil

    /// private constructor from a libxml document
    /// - Parameter xmlDocument: The XML document to parse
    @inlinable public init(xmlDocument: xmlDocPtr) {
        xml = xmlDocument
        xmlInitParser()
    }

    /// Initialise the XML parser from data with the given parser function
    /// - Parameters:
    ///   - data: The data to use for initialisation
    ///   - options: The parser options to use
    ///   - parser: The parse function to use; defaults to`xmlReadMemory`
    @inlinable public convenience init?(data: Data, options: ParserOptions = [.noWarning, .noError, .recover, .noNet], parser parse: (UnsafePointer<CChar>?, Int32, UnsafePointer<CChar>?, UnsafePointer<CChar>?, Int32) -> xmlDocPtr? = xmlReadMemory) {
        guard let xml = data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> xmlDocPtr? in
            guard let base = buffer.baseAddress?.assumingMemoryBound(to: CChar.self) else { return nil }
            return parse(base, Int32(buffer.count), "", nil, Int32(bitPattern: options.rawValue))
        }) else { return nil }
        self.init(xmlDocument: xml)
    }

    /// Failable initialiser from memory with a given parser function
    /// - Parameters:
    ///   - buffer: The buffer containing the XML to parse
    ///   - options: The parser options to use
    ///   - parser: The parse function to use; defaults to`xmlReadMemory`
    @inlinable public convenience init?(buffer: UnsafeBufferPointer<CChar>, options: ParserOptions = [.noWarning, .noError, .recover, .noNet], parser parse: (UnsafePointer<CChar>?, Int32, UnsafePointer<CChar>?, UnsafePointer<CChar>?, Int32) -> xmlDocPtr? = xmlReadMemory) {
        guard let base = buffer.baseAddress,
              let xml = parse(base, Int32(buffer.count), "", nil, Int32(bitPattern: options.rawValue)) else { return nil }
        self.init(xmlDocument: xml)
    }

    /// Initialise from an XML file
    /// - Parameters:
    ///   - fileName: The XML file to read
    @inlinable public convenience init?(fromFile fileName: UnsafePointer<CChar>) {
        guard let xml = xmlParseFile(fileName) else { return nil }
        self.init(xmlDocument: xml)
    }

    /// clean up
    deinit {
        xmlFreeDoc(xml)
//        if let ctx = ctx { xmlFreeParserCtxt(ctx) }
    }

    /// Return the tree's the root element
    public var rootElement: XMLElement {
        return XMLElement(node: xmlDocGetRootElement(xml))
    }

    /// Return the XML tree for enumeration
    public var tree: XMLTree {
        return XMLTree(xml: self)
    }

    /// Get an attribute value
    /// - Parameter attribute: The attriibute to get the value for
    /// - Returns: A String containing the attribute value, or `nil` if nonexistent
    public func valueFor(attribute: XMLAttribute) -> String? {
        let attr = attribute.attr
        guard let children = attr.pointee.children,
              let s = xmlNodeListGetString(xml, children, 1) else { return nil }
        let value = String(cString: UnsafePointer<xmlChar>(s))
        xmlFree(s)
        return value
    }

    /// get the value for a named attribute
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
    public func makeIterator() -> Iterator {
        return Iterator(root: rootElement)
    }
}


///
/// Tree enumeration
///
public struct XMLTree: Sequence {
    public typealias Node = (level: Int, node: XMLElement, parent: XMLElement?)
    let document: XMLDocument

    public init(xml: XMLDocument) {
        document = xml
    }

    public class Iterator: IteratorProtocol {
        let level: Int
        let parent: XMLElement?
        var element: XMLElement?
        var child: Iterator?

        /// create a generator from a root element
        init(root: XMLElement, parent: XMLElement? = nil, level: Int = 0) {
            self.level = level
            self.parent = parent
            element = root
        }

        /// return the next element following a depth-first pre-order traversal
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

    public func makeIterator() -> Iterator {
        return Iterator(root: document.rootElement)
    }
}
