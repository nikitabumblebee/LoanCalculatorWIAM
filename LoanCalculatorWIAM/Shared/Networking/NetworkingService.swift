//
//  NetworkingService.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 19.12.2025.
//

import Foundation
import Network
import Combine

class NetworkingService {
    static let shared = NetworkingService()
    let baseURL = "https://jsonplaceholder.typicode.com/posts"

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.LoanCalculatorWIAM.NetworkMonitor")
    private var isInternetAvailableSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private var isFirstCheckFinishedSubject: CurrentValueSubject<Bool, Never> = .init(false)

    private init() {
        handleMonitor()
    }

    func monitorInternetAvailability() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let cancellable = self.isInternetAvailableSubject
                .combineLatest(self.isFirstCheckFinishedSubject)
                .removeDuplicates(by: { $0.0 == $1.0 && $0.1 == $1.1 })
                .filter { $0.1 }
                .map { $0.0 }
                .sink(
                    receiveCompletion: { _ in
                        continuation.finish()
                    },
                    receiveValue: { isAvailable in
                        continuation.yield(isAvailable)
                    }
                )

            continuation.onTermination = { @Sendable _ in
                cancellable.cancel()
            }
        }
    }

    func sendRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return data
    }
    
    private func handleMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async { [weak self] in
                if self?.isFirstCheckFinishedSubject.value == false {
                    self?.isFirstCheckFinishedSubject.send(true)
                }
                self?.isInternetAvailableSubject.send(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}
