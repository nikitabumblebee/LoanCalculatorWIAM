//
//  ThemeManager.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 23.12.2025.
//

import Foundation
import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var colorScheme: AppTheme = AppTheme(rawValue: UserDefaults.standard.appColorScheme) ?? .system {
        didSet {
            saveColorScheme()
        }
    }

    @Published var isDarkMode: Bool = false

    init() {
        let saved = UserDefaults.standard.appColorScheme
        if let scheme = AppTheme(rawValue: saved) {
            self.colorScheme = scheme
        } else {
            self.colorScheme = .system
        }
        updateDarkModeStatus()
    }

    // MARK: - Dark Mode Detection

    func updateDarkModeStatus() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let isDark = windowScene.windows.first?.overrideUserInterfaceStyle == .dark
            DispatchQueue.main.async { [weak self] in
                self?.isDarkMode = isDark
            }
        }
    }

    // MARK: - Save & Load

    private func saveColorScheme() {
        UserDefaults.standard.appColorScheme = colorScheme.rawValue
    }

    private func loadColorScheme() {
        let saved = UserDefaults.standard.appColorScheme
        if let scheme = AppTheme(rawValue: saved) {
            colorScheme = scheme
        }
    }
}
