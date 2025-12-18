//
//  ConverterView.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import SwiftUI

struct ConverterView: View {
    let store: Store<LoanState, LoanAction>

    @State private var amountValue: Double
    @State private var durationValue: Double
    @State private var returnValue: Double
    @State private var returnDate: Date

    init(store: Store<LoanState, LoanAction>) {
        self.store = store
        _amountValue = State(initialValue: store.state.loan.amount)
        _durationValue = State(initialValue: Double(store.state.loan.duration))
        _returnValue = State(initialValue: Double(store.state.loan.returnAmount))
        _returnDate = State(initialValue: store.state.loan.returnDate)
    }

    var body: some View {
        VStack(spacing: 40) {
            // Amount Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("How much?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primaryText)
                    Spacer()
                    Text("$\(formatAmount(amountValue))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.currency)
                }

                Slider(value: $amountValue, in: 5_000...50_000, step: 1)
                    .padding(.top, 8)
                    .tint(.currency)
                    .onChange(of: amountValue) { _, newValue in
                        store.dispatch(.updateAmount(Double(newValue)))
                        updateValues()
                    }

                HStack {
                    Text("5000")
                        .foregroundStyle(Color.secondaryText)
                    Spacer()
                    Text("50000")
                        .foregroundStyle(Color.secondaryText)
                }
            }

            // Days Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("How long?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primaryText)
                    Spacer()
                    Text("\(Int(durationValue)) days")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.duration)
                }

                Slider(value: $durationValue, in: 7...28, step: 7)
                    .padding(.top, 8)
                    .tint(.duration)
                    .onChange(of: durationValue) { _, newValue in
                        store.dispatch(.updateDays(Int(newValue)))
                        updateValues()
                    }

                HStack {
                    Text("7")
                        .foregroundStyle(Color.secondaryText)
                    Spacer()
                    Text("28")
                        .foregroundStyle(Color.secondaryText)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Currency rate: \(store.state.loan.creditRate.formatted())%")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primaryText)

                    Text("Return date: \(returnDate.toDayMonthAndYear())")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primaryText)

                    Text("Return amount: \(formatAmount(returnValue))")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primaryText)
                }

                Spacer()
            }

            Button {
                store.dispatch(.sendLoan(store.state.loan))
            } label: {
                Text("Apply")
                    .font(.title3.bold())
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accept)
            .clipShape(.capsule)

        }
        .padding(32)
    }

    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    private func updateValues() {
        returnDate = store.state.loan.returnDate
        returnValue = store.state.loan.returnAmount
    }
}

#Preview {
    ConverterView(
        store: Store<LoanState, LoanAction>(
            initial: LoanState.init(loan: LoanModel(amount: 10000, duration: 14, creditRate: 15, processState: .idle)),
            reducer: { _, _ in  }
        )
    )
}
