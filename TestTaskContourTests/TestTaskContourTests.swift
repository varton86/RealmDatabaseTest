//
//  TestTaskContourTests.swift
//  TestTaskContourTests
//
//  Created by Oleg Soloviev on 09.02.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import XCTest
@testable import TestTaskContour

class TestTaskContourTests: XCTestCase {
    var sessionUnderTest: URLSession!

    override func setUp() {
        sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
    }

    override func tearDown() {
        sessionUnderTest = nil
    }

    func testValidCallToContourGetsHTTPStatusCode200() {
        let url = URL(string: "https://raw.githubusercontent.com/SkbkonturMobile/mobile-test-ios/master/json/generated-01.json")
        let promise = expectation(description: "Status code: 200")
        
        let dataTask = sessionUnderTest.dataTask(with: url!) { data, response, error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCallToContourCompletes() {
        let url = URL(string: "https://raw.githubusercontent.com/SkbkonturMobile/mobile-test-ios/master/json/generated-01.json")
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        let dataTask = sessionUnderTest.dataTask(with: url!) { data, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }

}
