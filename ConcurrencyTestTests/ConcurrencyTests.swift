//
//  ConcurrencyTestTests.swift
//  ConcurrencyTestTests
//


import XCTest
@testable import ConcurrencyTest

class ConcurrencyTests: XCTestCase {
    // below test case will run successfully if loadMessage will take less than 2 seconds
    // will fail if loadMessage will take greater than or equals to 2 seconds
    func testloadMessage() {
        let completeExpectation = self.expectation(description: "asyncTask")
        loadMessage { (testString) in
            completeExpectation.fulfill()
        }
        wait(for: [completeExpectation], timeout: 2.000000)
    }
}
