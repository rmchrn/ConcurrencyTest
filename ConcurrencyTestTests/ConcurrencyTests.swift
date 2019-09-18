//
//  ConcurrencyTestTests.swift
//  ConcurrencyTestTests
//


import XCTest
@testable import ConcurrencyTest

class ConcurrencyTests: XCTestCase {
    func testloadMessage() {
        let completeExpectation = self.expectation(description: "asyncTask")
        loadMessage { (testString) in
            completeExpectation.fulfill()
        }
        wait(for: [completeExpectation], timeout: 2.000000)
    }
}
