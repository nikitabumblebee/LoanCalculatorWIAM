//
//  LoanState.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

struct LoanState: Equatable {
    var loan: LoanModel
    var isInternetAvailable: Bool? = nil
    var notifyOnRestoreInternetConnection: Bool? = nil
}
