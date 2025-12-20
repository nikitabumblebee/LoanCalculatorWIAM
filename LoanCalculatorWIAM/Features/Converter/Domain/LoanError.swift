//
//  LoanError.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

enum LoanError: Error, Hashable {
    case invalidAmount
    case invalidDuration(String)
    case invalidCreditRate(String)
    case jsonMapping(String)
    case jsonEncoding
    case requestFailed
    case jsonDecoding
    case undefined
}

extension LoanError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid amount"
        case .invalidDuration(let message):
            return message
        case .invalidCreditRate(let message):
            return message
        case .jsonEncoding:
            return "Encoding error"
        case .requestFailed:
            return "Request failed"
        case .jsonDecoding:
            return "Decoding error"
        case .jsonMapping(let message):
            return message
        case .undefined:
            return nil
        }
    }
}
