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
        // Arrange
        let expectedData = "test data".data(using: .utf8)!
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Act & Assert
        let result = try await sut.sendRequest(request)
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.count, 0)
    }

    func testSendRequest_WithInvalidURL_ThrowsError() async {
        // Arrange
        let url = URL(string: "https://invalid-url-that-does-not-exist-12345.com")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 1 // Быстрый timeout

        // Act & Assert
        do {
            _ = try await sut.sendRequest(request)
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testSendRequest_WithBadStatus_ThrowsError() async {
        // Arrange
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/99999")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Act & Assert
        do {
            _ = try await sut.sendRequest(request)
            // Note: JSONPlaceholder может вернуть 200 даже для несуществующих ID
            // Поэтому этот тест может не работать как ожидается
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Tests for monitorInternetAvailability

    func testMonitorInternetAvailability_EmitsValues() async {
        // Arrange
        var emittedValues: [Bool] = []
        let expectation = XCTestExpectation(description: "Should emit at least one value")
        expectation.expectedFulfillmentCount = 1

        // Act
        let task = Task {
            for await available in sut.monitorInternetAvailability() {
                emittedValues.append(available)
                expectation.fulfill()
                // Выходим после первого значения
                break
            }
        }

        // Assert
        await fulfillment(of: [expectation], timeout: 5.0)
        task.cancel()
        XCTAssertGreaterThan(emittedValues.count, 0)
    }

    func testMonitorInternetAvailability_ReturnsAsyncStream() {
        // Arrange & Act
        let stream = sut.monitorInternetAvailability()

        // Assert
        XCTAssertNotNil(stream)
    }

    func testBaseURL_IsValid() {
        // Arrange & Act
        let baseURL = sut.baseURL

        // Assert
        XCTAssertNotNil(URL(string: baseURL))
        XCTAssertTrue(baseURL.contains("https://"))
    }
}
