//
//  MonthlyBudget.swift
//  BudgetBudget
//
//  Created by Leo Benz on 31.10.22.
//

import Foundation
import Combine
import os

class MonthlyBudget: ObservableObject, CustomDebugStringConvertible {
    var date: Date
    @Published var budgets: [CategoryBudget] = []
    @Published var budget: Budget
    
    private var cancellableBag = Set<AnyCancellable>()
    private var budgetedCancellables = Set<AnyCancellable>()
    private var balanceCancellables = Set<AnyCancellable>()
    private var spendCancellables = Set<AnyCancellable>()
    private var overspendCancellables = Set<AnyCancellable>()

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MonthlyBudget.self)
    )
    
    var debugDescription: String {
        return "MonthlyBudget: \(date.monthID), Categories: \(budgets.count)"
    }
    
    var previousBudget: MonthlyBudget? {
        budget.budgetFor(date: date.previousMonth())
    }
    
    init(date: Date, budget: Budget) {
        self.date = date
        self.uncategorized = 0
        self.budget = budget
        
        // Must be async because somehow the events get messed up due to the nested recursive initialization of previous months
        DispatchQueue.main.async { [self] in
            budget.moneymoney.$flatCategories.map { categories in
                print("CatBudget generator for month \(date.monthID): \(categories.debugDescription)")
                return MoneyMoney.filtered(categories:categories ?? []).map { category in
                    if let cat = self.budgets.first(where: { $0.category == category }) {
                        return cat
                    } else {
                        return CategoryBudget(category: category, date: date, budget: self)
                    }
                }
            }.assign(to: &$budgets)
        }
        
        budget.moneymoney.$flatCategories.sink { [self] categories in
            if let categories = categories {
                categories.first { $0.isDefault }!.$transactions.map({ transactions in
                    transactions.filter { $0.bookingDate.sameMonthAs(date)}.reduce(into: 0.0, { partialResult, transaction in
                        partialResult += transaction
                    })
                }).assign(to: &$uncategorized)
            }
        }.store(in: &cancellableBag)
        
        $budgets.sink { [self] budgets in
            overspendCancellables.forEach { $0.cancel() }
            budgets.forEach { budget in
                if !budget.category.isGroup {
                    budget.$overspend.sink { [self] newOverspend in
                        overspend = overspend - budget.overspend + newOverspend
                    }.store(in: &overspendCancellables)
                }
            }
        }.store(in: &cancellableBag)
        
        $budgets.sink { [self] budgets in
            budgetedCancellables.forEach { $0.cancel() }
            budgets.forEach { budget in
                if !budget.category.isGroup {
                    budget.$budgeted.sink { [self] newBudget in
                        budgeted = budgeted - budget.budgeted + newBudget
                    }.store(in: &budgetedCancellables)
                }
            }
        }.store(in: &cancellableBag)
        
        $budgets.sink { [self] budgets in
            balanceCancellables.forEach { $0.cancel() }
            budgets.forEach { budget in
                if !budget.category.isGroup {
                    budget.$available.sink { [self] newAvailable in
                        balance = balance - budget.available + newAvailable
                    }.store(in: &balanceCancellables)
                }
            }
        }.store(in: &cancellableBag)
        
        $budgets.sink { [self] budgets in
            spendCancellables.forEach { $0.cancel() }
            budgets.forEach { budget in
                if !budget.category.isGroup {
                    budget.$spend.sink { [self] newSpend in
                        spend = spend - budget.spend + newSpend
                    }.store(in: &spendCancellables)
                }
            }
        }.store(in: &cancellableBag)
        
        budget.moneymoney.$flatCategories.sink { [self] categories in
            if let categories = categories {
                categories.first { $0.isIncome }!.$transactions.map({ transactions in
                    transactions.filter { $0.bookingDate.sameMonthAs(date.previousMonth())}.reduce(into: 0.0, { partialResult, transaction in
                        partialResult += transaction
                    })
                }).assign(to: &$availableIncome)
            }
        }.store(in: &cancellableBag)
    }
    
    private var previousMonthToBudget: Double {
        previousBudget?.toBudget ?? 0
    }
    
    @Published private var availableIncome: Double = 0.0
    
    var availableFunds: Double {
        previousMonthToBudget + availableIncome
    }
    
    
    var overspendInPreviousMonth: Double {
        previousBudget?.overspend ?? 0
    }
    
    @Published var uncategorized: Double
    @Published var overspend: Double = 0.0
    @Published var budgeted: Double = 0.0
    @Published var balance: Double = 0.0
    @Published var spend: Double = 0.0
    
    var toBudget: Double {
        var toBudget = availableFunds - budgeted + overspendInPreviousMonth
        if !budget.settings.ignoreUncategorized {
            toBudget += uncategorized
        }
        return toBudget
    }
}
