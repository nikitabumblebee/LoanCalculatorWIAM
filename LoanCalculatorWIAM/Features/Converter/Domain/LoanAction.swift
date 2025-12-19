//
//  LoanAction.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

enum LoanAction {
    case checkInternet
    case internetConnectionFailed
    case internetConnectionRestored
    case resetInternetNotification
    case startProcessing(LoanModel)
    case sendLoan(LoanModel)
    case updateAmount(Double)
    case incorrectAmount
    case updateDays(Int)
    case submitLoanSuccess(LoanResponse)
    case submitLoanFailre(LoanError)
    case reset
}
