//
//  SwiftLibXMLTests.swift
//  SwiftLibXMLTests
//
//  Created by Rene Hexel on 15/05/2016.
//  Copyright © 2016, 2021 Rene Hexel. All rights reserved.
//
import XCTest
@testable import SwiftLibXML

let xmlVer = #"<?xml version="1.0"?>"#
let emptyXML = xmlVer + "<empty/>"
let helloXML = xmlVer + "<hello>world</hello>"
let someHTML = """
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Title</title>
    <link rel="stylesheet" href="some.css">
    <script src="some.js"></script>
  </head>
  <body>
    <p>Page Content</p>
  </body>
</html>
"""
let htmlNodeContent = [
    ("html", "Title", [("lang", "en")]),
    ("text", "", []),
    ("head", "Title", []),
    ("text", "", []),
    ("meta", "", [("charset", "utf-8")]),
    ("text", "", []),
    ("title", "Title", []),
    ("text", "Title", []),
    ("text", "", []),
    ("link", "", [("rel", "stylesheet"), ("href", "some.css")]),
    ("text", "", []),
    ("script", "", [("src", "some.js")]),
    ("text", "", []),
    ("text", "", []),
    ("body", "Page Content", []),
    ("text", "", []),
]

extension String: Error {}

final class SwiftLibXMLTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEmptyXML() throws {
        let xmlData = Data(emptyXML.utf8)
        let document = SwiftLibXML.XMLDocument(data: xmlData)
        XCTAssertNotNil(document)
        guard let document = document else { return }
        var previousElement: SwiftLibXML.XMLElement?
        let n = try document.reduce(0) {
            if $1.node == previousElement?.node { throw "\($1.name) @ \($1.node) === \(previousElement!.name) @ \(previousElement!.node) "}
            previousElement = $1
            return $0 + 1
        }
        XCTAssertEqual(n, 1)
        let node = document.makeIterator().next()
        XCTAssertNotNil(node)
        guard let node = node else { return }
        XCTAssertEqual(node.name, "empty")
    }

    func testElementXML() throws {
        let xmlData = Data(helloXML.utf8)
        let document = SwiftLibXML.XMLDocument(data: xmlData)
        XCTAssertNotNil(document)
        guard let document = document else { return }
        var previousElement: SwiftLibXML.XMLElement?
        let n = try document.reduce(0) {
            if $1.node == previousElement?.node { throw "\($1.name) @ \($1.node) === \(previousElement!.name) @ \(previousElement!.node) "}
            previousElement = $1
            return $0 + 1
        }
        XCTAssertEqual(n, 2)
        let node = document.makeIterator().next()
        XCTAssertNotNil(node)
        guard let node = node else { return }
        XCTAssertEqual(node.name, "hello")
        let contentNode = document.makeIterator().next()
        XCTAssertNotNil(contentNode)
        guard let contentNode = contentNode else { return }
        XCTAssertEqual(contentNode.content, "world")
    }

    func testHTML() throws {
        let xmlData = Data(someHTML.utf8)
        let document = SwiftLibXML.XMLDocument(data: xmlData, parser: htmlMemoryParser)
        XCTAssertNotNil(document)
        guard let document = document else { return }
        var previousElement: SwiftLibXML.XMLElement?
        let n = try document.reduce(0) {
            if $1.node == previousElement?.node { throw "\($1.name) @ \($1.node) === \(previousElement!.name) @ \(previousElement!.node) "}
            previousElement = $1
            return $0 + 1
        }
        XCTAssertEqual(n, htmlNodeContent.count)
        for (i, node) in document.enumerated() {
            let nc = htmlNodeContent[i]
            let name = nc.0
            let content = nc.1
            let attributes = nc.2
            let attributeCount = attributes.count
            XCTAssertEqual("\(i) name: \(node.name)", "\(i) name: \(name)")
            XCTAssertTrue(content.isEmpty || node.content.contains(content), "\(i) \(node.name): \(content)")
            for (j, attribute) in node.attributes.enumerated() {
                XCTAssertLessThan(j, attributeCount, "\(i) name: \(name)")
                guard j < attributeCount else { continue }
                XCTAssertEqual(attribute.name, attributes[j].0)
                XCTAssertEqual(node.attribute(named: attribute.name), attributes[j].1)
            }
        }
    }

    func testXPathHTML() throws {
        let xmlData = Data(someHTML.utf8)
        let document = SwiftLibXML.XMLDocument(data: xmlData, parser: htmlMemoryParser)
        XCTAssertNotNil(document)
        guard let document = document else { return }
        let xpath = document.xpath("//title")
        XCTAssertNotNil(xpath)
        guard let xpath = xpath else { return }
        XCTAssertEqual(xpath.count, 1)
        XCTAssertEqual(xpath[0].name, "title")
        XCTAssertEqual(xpath[0].content, "Title")
        XCTAssertEqual(document.xpath("//body")?.first?.content.trimmingCharacters(in: .whitespacesAndNewlines), "Page Content")
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
