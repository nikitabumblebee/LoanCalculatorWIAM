//
//  LoanRequest.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 19.12.2025.
//

import Foundation

struct LoanRequest: Codable {
    let amount: Double
    let period: Int
    let totalRepayment: Double
}
