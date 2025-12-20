//
//  ConverterSliderView.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 20.12.2025.
//

import SwiftUI

struct ConverterSliderView<T: BinaryFloatingPoint & Comparable>: View {
    @Binding var value: T
    let title: String
    let valueLabel: String
    let accentColor: Color
    let formatValue: Bool
    let step: T
    let minValue: T
    let maxValue: T
    var onChangeValue: (T) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.primaryText)
                Spacer()
                Text(valueLabel)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(accentColor)
            }

            Slider(
                value: Binding(
                    get: {
                        Double(self.value)
                    },
                    set: { newValue in
                        self.value = T(newValue)
                    }
                ),
                in: Double(minValue)...Double(maxValue),
                step: Double(step)
            )
                .padding(.top, 8)
                .tint(accentColor)
                .onChange(of: value) { _, newValue in
                    onChangeValue(newValue)
                }

            HStack {
                Text(String(Int(minValue)))
                    .foregroundStyle(Color.secondaryText)
                Spacer()
                Text(String(Int(maxValue)))
                    .foregroundStyle(Color.secondaryText)
            }
        }
    }
}
