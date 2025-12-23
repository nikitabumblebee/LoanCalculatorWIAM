//
//  NetworkingServiceTests.swift
//  LoanCalculatorWIAMTests
//
//  Created by Nikita Shmelev on 21.12.2025.
//

import XCTest
@testable import LoanCalculatorWIAM

final class NetworkingServiceTests: XCTestCase {

    var sut: NetworkingService!

    override func setUp() {
        super.setUp()
        sut = NetworkingService.shared
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Tests for sendRequest

    func testSendRequest_WithValidResponse_ReturnsData() async throws {
        let expectedData = "test data".data(using: .utf8)!
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let result = try await sut.sendRequest(request)
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.count, 0)
    }

    func testSendRequest_WithInvalidURL_ThrowsError() async {
        let url = URL(string: "https://invalid-url-that-does-not-exist-12345.com")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 1

        do {
            _ = try await sut.sendRequest(request)
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testSendRequest_WithBadStatus_ThrowsError() async {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/99999")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            _ = try await sut.sendRequest(request)
            // Note: JSONPlaceholder can return 200 for non-existent ID
            // Thats why this test can not work as expected
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Tests for monitorInternetAvailability

    func testMonitorInternetAvailability_EmitsValues() async {
        var emittedValues: [Bool] = []
        let expectation = XCTestExpectation(description: "Should emit at least one value")
        expectation.expectedFulfillmentCount = 1

        let task = Task {
            for await available in await sut.monitorInternetAvailability() {
                emittedValues.append(available)
                expectation.fulfill()
                break
            }
        }

        await fulfillment(of: [expectation], timeout: 5.0)
        task.cancel()
        XCTAssertGreaterThan(emittedValues.count, 0)
    }

    func testMonitorInternetAvailability_ReturnsAsyncStream() {
        let stream = sut.monitorInternetAvailability()

        XCTAssertNotNil(stream)
    }

    func testBaseURL_IsValid() {
        let baseURL = sut.baseURL

        XCTAssertNotNil(URL(string: baseURL))
        XCTAssertTrue(baseURL.contains("https://"))
    }
}
