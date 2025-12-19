//
//  Observer.swift
//  LoanCalculatorWIAM
//
//  Created by Nikita Shmelev on 18.12.2025.
//

import Foundation

enum ObserverStatus {
    case alive
    case dead
}

final class Observer<State> {
    let queue: DispatchQueue
    private let observeBlock: (State) -> ObserverStatus

    init(queue: DispatchQueue = .main, observe: @escaping (State) -> ObserverStatus) {
        self.queue = queue
        self.observeBlock = observe
    }

    func observe(_ state: State) -> ObserverStatus {
        return observeBlock(state)
    }
}

// Позволяет использовать Observer в Set, что необходимо
// для хранения наблюдателей в Store
extension Observer: Hashable {
    static func == (lhs: Observer<State>, rhs: Observer<State>) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
