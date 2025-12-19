//
//  ContentView.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ConverterView(
            store: Store<LoanState, LoanAction>(
                initial: LoanState(loan: LoanModel(creditRate: 15, processState: .idle)),
                reducer: loanConverterReducer,
                middleware: [AnyMiddleware(LoanValidation())]
            )
        )
    }
}

#Preview {
    ContentView()
}
