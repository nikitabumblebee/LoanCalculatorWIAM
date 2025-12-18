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
        state.loan.duration = days
    case .sendLoan(let loan):
        state.loan = loan
    }
}
