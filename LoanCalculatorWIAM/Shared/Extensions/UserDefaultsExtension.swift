//
//  UserDefaultsExtension.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 19.12.2025.
//

import Foundation

extension UserDefaults {
    @objc var lastAmount: Double {
        get {
            double(forKey: "lastAmount")
        }
        set {
            set(newValue, forKey: "lastAmount")
        }
    }
    
    @objc var lastPeriod: Int {
        get {
            integer(forKey: "lastPeriod")
        }
        set {
            set(newValue, forKey: "lastPeriod")
        }
    }
}
