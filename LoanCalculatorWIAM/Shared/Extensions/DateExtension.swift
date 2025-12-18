//
//  DateExtension.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

extension Date {
    func toDayMonthAndYear() -> String {
        let dateFormatter = DateFormatter()

        // Устанавливаем локаль для корректных названий месяцев
        dateFormatter.locale = Locale(identifier: "ru_RU")

        // Формат: "18-12-2025" (день-месяц-год)
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: self)

        return formattedDate
    }
}
