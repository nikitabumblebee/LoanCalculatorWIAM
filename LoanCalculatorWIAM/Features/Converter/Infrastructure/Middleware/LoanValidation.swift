//
//  LoanValidation.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

struct LoanValidation: Middleware {
    typealias State = LoanState

    typealias Action = LoanAction

    func process(
        action: Action,
        state: State,
        next: @escaping (Action) -> Void
    ) {
        switch action {
        case .updateAmount(let amount):
            next(action)
        case .sendLoan(let loanModel):
            next(action)
        case .updateDays(let days):
            next(action)
        }
    }
}
