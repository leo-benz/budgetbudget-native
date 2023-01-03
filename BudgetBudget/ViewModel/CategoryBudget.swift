//
//  CategoryBudget.swift
//  BudgetBudget
//
//  Created by Leo Benz on 31.10.22.
//

import Foundation
import Combine
import os

class CategoryBudget: Identifiable, ObservableObject, Hashable {
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
    
    private var prevCancellable: AnyCancellable?
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CategoryBudget.self)
    )
    
    init(category: Category, date: Date, budget: MonthlyBudget) {
        //            Self.logger.debug("Init Category \(category) \(date)")
        self.category = category
        self.date = date
        self.available = 0
        self.budget = budget
        if category.isGroup {
            budget.$budgets.sink { budgets in
                self.cancellableBag.forEach { $0.cancel() }
                category.children?.forEach({ child in
                    if let childBudget = budgets.first(where: { $0.category == child }) {
                        childBudget.$budgeted.sink {
                            self.budgeted = self.budgeted - childBudget.budgeted + $0
                        }.store(in: &self.cancellableBag)
                        childBudget.$spend.sink {
                            self.spend = self.spend - childBudget.spend + $0
                        }.store(in: &self.cancellableBag)
                        childBudget.$available.sink {
                            self.available = self.available - childBudget.available + $0
                        }.store(in: &self.cancellableBag)
                    }
                })
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
