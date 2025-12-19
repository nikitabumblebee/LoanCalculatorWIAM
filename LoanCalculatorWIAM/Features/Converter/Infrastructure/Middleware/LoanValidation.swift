//
//  LoanValidation.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

struct LoanValidation: Middleware {
    typealias State = LoanState
    typealias Action = LoanAction

    private let networkingService = NetworkingService.shared

    private enum Constants {
        static let maxRetryCount: Int = 3
        static let minAmount: Double = 5_000
        static let maxAmount: Double = 50_000
    }

    func process(
        action: Action,
        state: State,
        next: @escaping (Action) -> Void
    ) {
        switch action {
        case .updateAmount(let amount):
            guard amount >= Constants.minAmount, amount <= Constants.maxAmount else {
                next(.incorrectAmount)
                return
            }
            next(action)
        case .updateDays:
            next(action)
        case .startProcessing(let loanModel):
            saveLastData(amount: loanModel.amount, period: loanModel.period)
            next(action)
        case .sendLoan(let loanModel):
            Task {
                let loanAction = await self.tryToSendRequest(loanModel: loanModel, retryCount: 0)
                next(loanAction)
            }
        case .submitLoanSuccess:
            next(action)
        case .submitLoanFailre:
            next(action)
        case .reset:
            next(action)
        case .checkInternet:
            Task {
                for await available in networkingService.monitorInternetAvailability() {
                    if available {
                        next(.internetConnectionRestored)
                    } else {
                        next(.internetConnectionFailed)
                    }
                }
            }
        case .internetConnectionFailed:
            next(action)
        case .internetConnectionRestored:
            next(action)
        case .resetInternetNotification:
            next(action)
        case .incorrectAmount:
            next(action)
        }
    }

    private func tryToSendRequest(loanModel: LoanModel, retryCount: Int) async -> Action {
        guard let url = URL(string: networkingService.baseURL) else { return .submitLoanFailre(LoanError.undefined) }
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let loanRequest = LoanRequest(
            amount: loanModel.amount,
            period: loanModel.period,
            totalRepayment: loanModel.returnAmount
        )

        do {
            let httpBody = try encode(loanRequest: loanRequest)
            request.httpBody = httpBody
            let data = try await sendRequest(request)
            let response = try decode(from: data)
            return .submitLoanSuccess(response)
        } catch {
            if retryCount < Constants.maxRetryCount {
                try? await Task.sleep(for: .seconds(2))
                return await tryToSendRequest(loanModel: loanModel, retryCount: retryCount + 1)
            } else {
                if let error = error as? LoanError {
                    switch error {
                    case .jsonDecoding:
                        return .submitLoanFailre(LoanError.jsonEncoding)
                    case .requestFailed:
                        return .submitLoanFailre(LoanError.requestFailed)
                    case .jsonEncoding:
                        return .submitLoanFailre(LoanError.jsonEncoding)
                    default:
                        return .submitLoanFailre(LoanError.undefined)
                    }
                }
                return .submitLoanFailre(LoanError.undefined)
            }
        }
    }

    private func encode(loanRequest: LoanRequest) throws -> Data {
        do {
            return try JSONEncoder().encode(loanRequest)
        } catch {
            throw LoanError.jsonEncoding
        }
    }

    private func sendRequest(_ request: URLRequest) async throws -> Data {
        do {
            return try await NetworkingService.shared.sendRequest(request)
        } catch {
            throw LoanError.requestFailed
        }
    }

    private func decode(from data: Data) throws -> LoanResponse {
        do {
            return try JSONDecoder().decode(LoanResponse.self, from: data)
        } catch {
            throw LoanError.jsonDecoding
        }
    }

    private func saveLastData(amount: Double, period: Int) {
        UserDefaults.standard.lastAmount = amount
        UserDefaults.standard.lastPeriod = period
    }
}
