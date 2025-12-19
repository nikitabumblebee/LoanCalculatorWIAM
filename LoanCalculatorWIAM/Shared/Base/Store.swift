//
//  Store.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation
import Combine

class Store<State, Action>: ObservableObject where State: Equatable {
    @Published private(set) var state: State
    private let reducer: (inout State, Action) -> Void
    private var observers: Set<Observer<State>> = []
    private var middleware: [AnyMiddleware<State, Action>]
    private let queue = DispatchQueue(label: "com.LoanCalculatorWIAM.Store-queue", qos: .userInitiated)

    init(
        initial state: State,
        reducer: @escaping (inout State, Action) -> Void,
        middleware: [AnyMiddleware<State, Action>] = []
    ) {
        self.reducer = reducer
        self.state = state
        self.middleware = middleware
    }

    func dispatch(_ action: Action) {
        queue.sync { [weak self] in
            guard let self else { return }
            let middlewareChain = middleware.reversed().reduce({ action in
                self.reducer(&self.state, action)
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send()
                }
                self.notifyObservers()
            }) { next, mw in
                return { action in
                    mw.process(action: action, state: self.state, next: next)
                }
            }
            middlewareChain(action)
        }
    }

    func subscribe(observer: Observer<State>) {
        queue.sync { [weak self] in
            self?.observers.insert(observer)
            self?.notify(observer)
        }
    }

    private func notifyObservers() {
        for observer in observers {
            notify(observer)
        }
    }

    private func notify(_ observer: Observer<State>) {
        let state = self.state
        observer.queue.async { [weak self] in
            guard let self else { return }
            if observer.observe(state) == .dead {
                self.queue.async { [weak self] in
                    guard let self else { return }
                    self.observers.remove(observer)
                }
            }
        }
    }
}
