//
//  ConverterView.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import SwiftUI
import Combine

struct ConverterView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let store: Store<LoanState, LoanAction>

    @State private var amountValue: Double
    @State private var durationValue: Double
    @State private var returnValue: Double
    @State private var returnDate: Date
    @State private var processState: LoanProcessState
    @State private var showAlert: Bool = false
    @State private var alertModel: AlertModel = AlertModel(title: "", message: "")

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
            Picker("Theme", selection: $themeManager.colorScheme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.title)
                        .tag(theme)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 240)

            Spacer()

            // Amount Slider
            ConverterSliderView(
                value: $amountValue,
                title: "How much?",
                valueLabel: "$\(amountValue.formatAmount())",
                accentColor: .currency,
                rangeValue: 5_000...50_000,
                step: 1,
            ) { value in
                store.dispatch(.updateAmount(value))
                updateValues()
            }

            ConverterSliderView(
                value: $durationValue,
                title: "How long?",
                valueLabel: "\(Int(durationValue)) days",
                accentColor: .duration,
                rangeValue: 7...28,
                step: 7,
            ) { value in
                store.dispatch(.updateDays(Int(value)))
                updateValues()
            }

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Currency rate: \(store.state.loan.creditRate.formatted())%")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primaryText)

                    Text("Return date: \(returnDate.toDayMonthAndYear())")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primaryText)

                    Text("Return amount: \(returnValue.formatAmount())")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primaryText)
                }

                Spacer()
            }

            Spacer()

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
                        alertModel = AlertModel(title: "Error", message: error.localizedDescription)
                        showAlert = true
                    case .finish:
                        alertModel = AlertModel(title: "Success", message: "Your request for loan was successfully sent")
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
                        alertModel = AlertModel(title: "No internet connection", message: "Internet connection was failed. Please try again later")
                        showAlert = true
                        store.dispatch(.resetInternetNotification)
                    } else {
                        if showAlert {
                            showAlert = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                alertModel = AlertModel(title: "Internet connection restored", message: "")
                                showAlert = true
                                store.dispatch(.resetInternetNotification)
                            }
                        } else {
                            alertModel = AlertModel(title: "Internet connection restored", message: "")
                            showAlert = true
                            store.dispatch(.resetInternetNotification)
                        }
                    }
                }
            }
        )
        .alert(
            alertModel.title,
            isPresented: $showAlert
        ) {
            Button("Ok", role: .cancel) {
                store.dispatch(.reset)
            }
        } message: {
            Text(alertModel.message)
        }
        .onAppear {
            store.dispatch(.checkInternet)
        }
        .preferredColorScheme(themeManager.colorScheme.colorScheme)
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
