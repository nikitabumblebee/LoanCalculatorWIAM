//
//  LoanError.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

enum LoanError: Error, Hashable {
    case invalidAmount(String)
    case invalidDuration(String)
    case invalidCreditRate(String)
    case jsonMapping(String)
    case undefined
}

extension LoanError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidAmount(let message):
            return message
        case .invalidDuration(let message):
            return message
        case .invalidCreditRate(let message):
            return message
        case .jsonMapping(let message):
            return message
        case .undefined:
            return nil
        }
    }
}
