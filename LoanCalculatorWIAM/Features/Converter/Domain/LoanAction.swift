//
//  LoanAction.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

enum LoanAction {
    case sendLoan(LoanModel)
    case updateAmount(Double)
    case updateDays(Int)
}
