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
    let rangeValue: ClosedRange<T>
    let step: T
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
                in: Double(rangeValue.lowerBound)...Double(rangeValue.upperBound),
                step: Double(step)
            )
            .padding(.top, 8)
            .tint(accentColor)
            .onChange(of: value) { _, newValue in
                onChangeValue(newValue)
            }

            HStack {
                Text(String(Double(rangeValue.lowerBound).formatAmount()))
                    .foregroundStyle(Color.secondaryText)
                Spacer()
                Text(String(Double(rangeValue.upperBound).formatAmount()))
                    .foregroundStyle(Color.secondaryText)
            }
        }
    }
}
