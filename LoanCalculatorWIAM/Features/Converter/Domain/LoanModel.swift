//
//  LoanModel.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

struct LoanModel: Hashable, Identifiable {
    var id: UUID = UUID()
    var amount: Double
    var duration: Int
    var creditRate: Double
    var processState: LoanProcessState

    var returnAmount: Double {
        let today = Date()
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: today))
        let startOfNextYear = calendar.date(from: DateComponents(year: calendar.component(.year, from: today) + 1, month: 1, day: 1))
        let endOfYear = calendar.date(byAdding: .day, value: 0, to: startOfNextYear ?? today)
        let days = calendar.dateComponents([.day], from: startOfYear ?? today, to: endOfYear ?? today).day ?? 365 + 1
        let creditDuration = Double(duration) / Double(days)
        let rate = creditRate / Double(100)
        let value = (amount * (1 + creditDuration * rate)).roundedToTwoDecimalPlaces(2)
        return value
    }
    var returnDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: duration, to: Date()) ?? Date()
    }
}


enum LoanProcessState: Hashable {
    case idle
    case processing
    case retry(Int)
    case finish
    case error(LoanError)
}
