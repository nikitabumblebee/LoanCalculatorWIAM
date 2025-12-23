//
//  LoanValidationTests.swift
//  LoanCalculatorWIAMTests
//
//  Created by Nikita Shmelev on 21.12.2025.
//

import XCTest
@testable import LoanCalculatorWIAM

final class LoanValidationTests: XCTestCase {

    var sut: LoanValidation!
    var mockState: LoanState!

    override func setUp() {
        super.setUp()
        sut = LoanValidation()
        mockState = LoanState(loan: LoanModel(creditRate: 15, processState: .idle))
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        mockState = nil
    }

    // MARK: - Tests for updateAmount validation

    func testProcess_WithValidAmount_CallsNext() {
        let validAmount = 25_000.0
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .updateAmount(validAmount),
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .updateAmount(let amount) = receivedAction {
            XCTAssertEqual(amount, validAmount)
        } else {
            XCTFail("Expected updateAmount action")
        }
    }

    func testProcess_WithAmountTooLow_ReturnsIncorrectAmount() {
        // Less than minAmount (5_000)
        let tooLowAmount = 1_000.0
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .updateAmount(tooLowAmount),
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .incorrectAmount = receivedAction {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected incorrectAmount action")
        }
    }

    func testProcess_WithAmountTooHigh_ReturnsIncorrectAmount() {
        // More than maxAmount (50_000)
        let tooHighAmount = 100_000.0
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .updateAmount(tooHighAmount),
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .incorrectAmount = receivedAction {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected incorrectAmount action")
        }
    }

    // MARK: - Tests for updateDays

    func testProcess_WithUpdateDays_CallsNext() {
        let days = 21
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .updateDays(days),
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .updateDays(let receivedDays) = receivedAction {
            XCTAssertEqual(receivedDays, days)
        } else {
            XCTFail("Expected updateDays action")
        }
    }

    // MARK: - Tests for startProcessing

    func testProcess_WithStartProcessing_SavesDataAndCallsNext() {
        let loanModel = LoanModel(creditRate: 15, processState: .idle)
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        // Save current values in UserDefaults
        let currentAmount = UserDefaults.standard.lastAmount
        let currentPeriod = UserDefaults.standard.lastPeriod

        sut.process(
            action: .startProcessing(loanModel),
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .startProcessing = receivedAction {
            XCTAssertEqual(UserDefaults.standard.lastAmount, loanModel.amount)
            XCTAssertEqual(UserDefaults.standard.lastPeriod, loanModel.period)
        } else {
            XCTFail("Expected startProcessing action")
        }

        // Cleanup
        UserDefaults.standard.lastAmount = currentAmount
        UserDefaults.standard.lastPeriod = currentPeriod
    }

    // MARK: - Tests for reset action

    func testProcess_WithReset_CallsNext() {
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .reset,
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .reset = receivedAction {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected reset action")
        }
    }

    // MARK: - Tests for internet connection actions

    func testProcess_WithInternetConnectionFailed_CallsNext() {
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .internetConnectionFailed,
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .internetConnectionFailed = receivedAction {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected internetConnectionFailed action")
        }
    }

    func testProcess_WithInternetConnectionRestored_CallsNext() {
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .internetConnectionRestored,
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .internetConnectionRestored = receivedAction {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected internetConnectionRestored action")
        }
    }

    // MARK: - Tests for success/failure actions

    func testProcess_WithSubmitLoanSuccess_CallsNext() {
        let mockResponse = LoanResponse(id: "1")
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .submitLoanSuccess(mockResponse),
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .submitLoanSuccess = receivedAction {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected submitLoanSuccess action")
        }
    }

    func testProcess_WithSubmitLoanFailure_CallsNext() {
        let error = LoanError.requestFailed
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .submitLoanFailre(error),
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .submitLoanFailre = receivedAction {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected submitLoanFailre action")
        }
    }

    // MARK: - Boundary tests

    func testProcess_WithMinValidAmount_Succeeds() {
        let minValidAmount = 5_000.0
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .updateAmount(minValidAmount),
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .updateAmount = receivedAction {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected updateAmount action")
        }
    }

    func testProcess_WithMaxValidAmount_Succeeds() {
        let maxValidAmount = 50_000.0
        let expectation = XCTestExpectation(description: "next should be called")
        var receivedAction: LoanAction?

        sut.process(
            action: .updateAmount(maxValidAmount),
            state: mockState,
            next: { action in
                receivedAction = action
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        if case .updateAmount = receivedAction {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected updateAmount action")
        }
    }
}
