//
//  SwiftLibXMLTests.swift
//  SwiftLibXMLTests
//
//  Created by Rene Hexel on 15/05/2016.
//  Copyright © 2016, 2021 Rene Hexel. All rights reserved.
//

import XCTest
@testable import SwiftLibXML

class SwiftLibXMLTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

extension SwiftLibXMLTests {
    static var allTests: [(String, (SwiftLibXMLTests) -> () throws -> Void)] {
        return [
            ("testExample",            testExample),
            ("testPerformanceExample", testPerformanceExample),
        ]
    }
}

