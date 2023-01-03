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
    private var budgetedCancellables = [CategoryBudget: AnyCancellable]()
    private var balanceCancellables = [CategoryBudget: AnyCancellable]()
    private var spendCancellables = [CategoryBudget: AnyCancellable]()
    private var overspendCancellables = [CategoryBudget: AnyCancellable]()
    private var incomeCancellables = Set<AnyCancellable>()

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
    
    @Published private var categoryIncomes: [Category: Double] = [:]
    
    init(date: Date, budget: Budget) {
        self.date = date
        self.uncategorized = 0
        self.budget = budget
        
        // Must be async because somehow the events get messed up due to the nested recursive initialization of previous months
        DispatchQueue.main.async { [self] in
            budget.moneymoney.$flatCategories.map { categories in
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
            let removedBudgets = overspendCancellables.filter { !budgets.contains($0.key) }
            removedBudgets.forEach {
                $0.value.cancel()
                overspendCancellables.removeValue(forKey: $0.key)
                overspend = overspend - $0.key.overspend
            }
            
            let newBudgets = budgets.filter { overspendCancellables[$0] == nil && !$0.category.isGroup}
            newBudgets.forEach { budget in
                overspend = overspend + budget.overspend
                let sink = budget.$overspend.sink { [self] newOverspend in
                    overspend = overspend - budget.overspend + newOverspend
                }
                overspendCancellables[budget] = sink
            }
        }.store(in: &cancellableBag)
        
        $budgets.sink { [self] budgets in
            let removedBudgets = budgetedCancellables.filter { !budgets.contains($0.key) }
            removedBudgets.forEach {
                $0.value.cancel()
                budgetedCancellables.removeValue(forKey: $0.key)
                budgeted = budgeted - $0.key.budgeted
            }
            
            let newBudgets = budgets.filter { budgetedCancellables[$0] == nil && !$0.category.isGroup}
            newBudgets.forEach { budget in
                budgeted = budgeted + budget.budgeted
                let sink = budget.$budgeted.sink { [self] newBudget in
                    budgeted = budgeted - budget.budgeted + newBudget
                }
                budgetedCancellables[budget] = sink
            }
        }.store(in: &cancellableBag)
        
        $budgets.sink { [self] budgets in
            let removedBudgets = balanceCancellables.filter { !budgets.contains($0.key) }
            removedBudgets.forEach {
                $0.value.cancel()
                balanceCancellables.removeValue(forKey: $0.key)
                balance = balance - $0.key.available
            }
            
            let newBudgets = budgets.filter { balanceCancellables[$0] == nil && !$0.category.isGroup}
            newBudgets.forEach { budget in
                balance = balance + budget.available
                let sink = budget.$available.sink { [self] newAvailable in
                    balance = balance - budget.available + newAvailable
                }
                balanceCancellables[budget] = sink
            }
        }.store(in: &cancellableBag)
        
        $budgets.sink { [self] budgets in
            let removedBudgets = spendCancellables.filter { !budgets.contains($0.key) }
            removedBudgets.forEach {
                $0.value.cancel()
                spendCancellables.removeValue(forKey: $0.key)
                spend = spend - $0.key.spend
            }
            
            let newBudgets = budgets.filter { spendCancellables[$0] == nil && !$0.category.isGroup}
            newBudgets.forEach { budget in
                spend = spend + budget.spend
                let sink = budget.$spend.sink { [self] newSpend in
                    spend = spend - budget.spend + newSpend
                }
                spendCancellables[budget] = sink
            }
        }.store(in: &cancellableBag)
        
        budget.moneymoney.$flatCategories
            .compactMap { optionalCategories in optionalCategories }.sink { [self] categories in
                categoryIncomes.removeAll()
                incomeCancellables.forEach { $0.cancel() }
                incomeCancellables.removeAll()
                categories.filter { $0.isIncome }.forEach { category in
                    category.$transactions.sink { transactions in
                        transactions.publisher
                            .filter { transaction in transaction.bookingDate.sameMonthAs(date.previousMonth()) }
                            .reduce(0.0, +)
                            .sink { [self] in
                                categoryIncomes[category] = $0
                            }
                    }.store(in: &incomeCancellables)
                }
            }.store(in: &cancellableBag)
        
        $categoryIncomes.sink { [self] in
            $0.values.publisher.reduce(0.0, +).assign(to: &$availableIncome)
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
