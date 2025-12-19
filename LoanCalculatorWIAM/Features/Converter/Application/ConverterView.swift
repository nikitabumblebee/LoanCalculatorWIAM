//
//  ConverterView.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import SwiftUI
import Combine

struct ConverterView: View {
    let store: Store<LoanState, LoanAction>

    @State private var amountValue: Double
    @State private var durationValue: Double
    @State private var returnValue: Double
    @State private var returnDate: Date
    @State private var processState: LoanProcessState
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""

    init(store: Store<LoanState, LoanAction>) {
        self.store = store
        _amountValue = State(initialValue: store.state.loan.amount)
        _durationValue = State(initialValue: Double(store.state.loan.period))
        _returnValue = State(initialValue: Double(store.state.loan.returnAmount))
        _returnDate = State(initialValue: store.state.loan.returnDate)
        _processState = State(initialValue: store.state.loan.processState)
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
                store.dispatch(.startProcessing(store.state.loan))
            } label: {
                if processState == .processing {
                    HStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.8)
                        Text("Processing...")
                            .font(.title3.bold())
                            .foregroundStyle(Color.white)
                    }
                } else {
                    Text("Submit an application")
                        .font(.title3.bold())
                        .foregroundStyle(Color.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background((processState == .processing || store.state.isInternetAvailable == false) ? Color.gray.opacity(0.3) : Color.accept)
            .clipShape(.capsule)
            .disabled(processState == .processing || store.state.isInternetAvailable == false)
        }
        .padding(32)
        .onReceive(
            store.objectWillChange,
            perform: { _ in
                if processState != store.state.loan.processState {
                    switch store.state.loan.processState {
                    case .error(let error):
                        alertTitle = "Error"
                        alertMessage = "Something went wrong!\n\(error.localizedDescription)"
                        showAlert = true
                    case .finish:
                        alertTitle = "Success"
                        alertMessage = "Your request for loan was successfully sent"
                        showAlert = true
                    case .processing:
                        store.dispatch(.sendLoan(store.state.loan))
                    default:
                        break
                    }
                    processState = store.state.loan.processState
                }
                if store.state.notifyOnRestoreInternetConnection == true {
                    if store.state.isInternetAvailable == false {
                        alertTitle = "No internet connection"
                        alertMessage = "Internet connection was failed. Please try again later"
                        showAlert = true
                        store.dispatch(.resetInternetNotification)
                    } else {
                        if showAlert {
                            showAlert = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                alertTitle = "Internet connection restored"
                                alertMessage = ""
                                showAlert = true
                                store.dispatch(.resetInternetNotification)
                            }
                        } else {
                            alertTitle = "Internet connection restored"
                            alertMessage = ""
                            showAlert = true
                            store.dispatch(.resetInternetNotification)
                        }
                    }
                }
                if store.state.isIncorrectAmount {
                    alertTitle = "Incorrect amount"
                    alertMessage = "Please change amount according to limitation"
                    showAlert = true
                    store.dispatch(.reset)
                }
            }
        )
        .alert(
            alertTitle,
            isPresented: $showAlert
        ) {
            Button("Ok", role: .cancel) {
                store.dispatch(.reset)
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            store.dispatch(.checkInternet)
        }
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
            initial: LoanState.init(loan: LoanModel(amount: 10000, period: 14, creditRate: 15, processState: .idle)),
            reducer: { _, _ in  }
        )
    )
}
