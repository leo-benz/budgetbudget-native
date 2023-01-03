//
//  CategoryBudget.swift
//  BudgetBudget
//
//  Created by Leo Benz on 31.10.22.
//

import Foundation
import Combine
import os

class CategoryBudget: Identifiable, ObservableObject, Hashable, CustomDebugStringConvertible {
    var debugDescription: String {
        "\(category.name) \(category.isGroup ? "(G)" : ""): \(date.monthID)"
    }
    
    static func == (lhs: CategoryBudget, rhs: CategoryBudget) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var category: Category
    @Published var budgeted: Double = 0
    @Published var spend: Double = 0
    @Published var available: Double = 0
    @Published var overspend: Double = 0
    
    var id = UUID()
    private var date: Date
    private var budget: MonthlyBudget
    
    private var cancellableBag = Set<AnyCancellable>()
    private var childCancellableBag = [CategoryBudget: Set<AnyCancellable>]()
    
    private var prevCancellable: AnyCancellable?
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CategoryBudget.self)
    )
    
    init(category: Category, date: Date, budget: MonthlyBudget) {
        self.category = category
        self.date = date
        self.available = 0
        self.budget = budget
        if category.isGroup {
            budget.$budgets.sink { [self] budgets in
                let childBudgets = budgets.filter { budget in category.children?.contains{ child in budget.category == child} ?? false}
                let removedBudgets = childCancellableBag.filter { !childBudgets.contains($0.key) }
                removedBudgets.forEach { removedBudget in
                    removedBudget.value.forEach { $0.cancel()}
                    childCancellableBag.removeValue(forKey: removedBudget.key)
                    budgeted = budgeted - removedBudget.key.budgeted
                    spend = spend - removedBudget.key.spend
                    available = available - removedBudget.key.available
                }
                
                let newBudgets = childBudgets.filter { childCancellableBag[$0] == nil }
                newBudgets.forEach { budget in
                    budgeted = budgeted + budget.budgeted
                    spend = spend + budget.spend
                    available = available + budget.available
                    
                    let budgetedSink = budget.$budgeted.sink { [self] newBudgeted in
                        budgeted = budgeted - budget.budgeted + newBudgeted
                    }
                    
                    let spendSink = budget.$spend.sink { [self] newSpend in
                        spend = spend - budget.spend + newSpend
                    }
                    
                    let availableSink = budget.$available.sink { [self] newAvailable in
                        available = available - budget.available + newAvailable
                    }
                    childCancellableBag[budget] = [budgetedSink, spendSink, availableSink]
                }
            }.store(in: &cancellableBag)
        } else {
            category.$transactions.map { transactions in
                let currentMonthTransactions = transactions.filter { $0.bookingDate.sameMonthAs(date)}
                return currentMonthTransactions.reduce(into: 0.0) { partialResult, transaction in
                    partialResult += transaction
                }
            }.sink { [self] in
                spend = $0
            }.store(in: &cancellableBag)
            
            prevCancellable = budget.previousBudget?.$budgets.sink { [self] prevBudgets in
                if let prevCategory = prevBudgets.first(where: { $0.category == category }) {
                    $spend.combineLatest($budgeted, prevCategory.$available)
                        .map { spent, budgeted, prevMonthAvailable in
                            max(0, prevMonthAvailable) + budgeted + spent
                        }.assign(to: &$available)
                    $available.map { available in
                        min(0, available)
                    }.assign(to: &$overspend)
                    prevCancellable?.cancel()
                }
            }
            
            // Must be initiallied later so that categroies are initialized to pick up the initial value
            DispatchQueue.main.async { [self] in
                budgeted = UserDefaults.standard.double(forKey: "Category-\(self.category.id)-\(self.date.monthID):Budgeted")
                $budgeted.sink { [weak self] budgeted in
                    if let self = self {
                        UserDefaults.standard.set(budgeted, forKey: "Category-\(self.category.id)-\(self.date.monthID):Budgeted")
                    }
                }.store(in: &cancellableBag)
            }
        }
    }
}
