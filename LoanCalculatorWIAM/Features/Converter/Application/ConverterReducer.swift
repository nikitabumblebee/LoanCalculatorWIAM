//
//  ConverterReducer.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

func loanConverterReducer(_ state: inout LoanState, action: LoanAction) {
    switch action {
    case .updateAmount(let amount):
        state.loan.amount = amount
    case .updateDays(let days):
        state.loan.period = days
    case .startProcessing:
        state.loan.processState = .processing
    case .sendLoan(let loan):
        state.loan = loan
    case .submitLoanFailre(let error):
        state.loan.processState = .error(error)
    case .submitLoanSuccess(let response):
        state.loan.processState = .finish
    case .reset:
        state.loan.processState = .idle
        state.isIncorrectAmount = false
    case .checkInternet:
        break
    case .internetConnectionFailed:
        state.notifyOnRestoreInternetConnection = true
        state.isInternetAvailable = false
    case .internetConnectionRestored:
        guard state.isInternetAvailable == false else { return }
        state.notifyOnRestoreInternetConnection = true
        state.isInternetAvailable = true
    case .resetInternetNotification:
        state.notifyOnRestoreInternetConnection = nil
    case .incorrectAmount:
        state.isIncorrectAmount = true
    }
}
