//
//  Budget.swift
//  BudgetBudget
//
//  Created by Leo Benz on 29.07.22.
//

import Foundation
import Combine
import os

class Budget: ObservableObject {

    @Published var name: String = "Default"

    @Published var settings: Settings
    @Published var moneymoney = MoneyMoney()

    private var monthlyBudgets: [Date: MonthlyBudget] = [:]
    private var subscribers: Set<AnyCancellable> = []

    init() {
        settings = UserDefaults.standard.codable(forKey: "Settings") ?? Settings()
        $settings.sink { setting in
            UserDefaults.standard.set(value: setting, forKey: "Settings")
        }.store(in: &subscribers)
    }

    func budgetFor(date: Date) -> MonthlyBudget {
        let monthlyBudget = monthlyBudgets[date]

        if let monthlyBudget = monthlyBudget {
            return monthlyBudget
        } else {
            let budget = MonthlyBudget(date: date, budget: self)
            monthlyBudgets[date] = budget
            return budget
        }
    }

    class MonthlyBudget: ObservableObject, CustomDebugStringConvertible {
        var date: Date
        @Published var budgets: [CategoryBudget] = []
        var uncategorized: Double
        var budget: Budget
        private var moneymoney: MoneyMoney
        private var settings: Settings

        private var cancellableBag = Set<AnyCancellable>()
        
        private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: MonthlyBudget.self)
        )
        
        var debugDescription: String {
            return "MonthlyBudget: \(date.monthID), Categories: \(budgets.count)"
        }

        var previousBudget: MonthlyBudget {
            budget.budgetFor(date: date.previousMonth())
        }

        init(date: Date, budget: Budget) {
            self.date = date
            self.uncategorized = 0
            self.budget = budget
            self.settings = budget.settings
            self.moneymoney = budget.moneymoney
            updateBasedOn(categories: moneymoney.filteredFlatCategories)
            moneymoney.$flatCategories.sink { [weak self] value in
//                Self.logger.debug("Flat categories update \(value?.debugDescription ?? "Nil")")
                self?.updateBasedOn(categories: self?.moneymoney.filtered(categories: value ?? []))
            }.store(in: &cancellableBag)
        }

        private func updateBasedOn(categories: [Category]?) {
            // TODO: Save and Load previous values
            budgets = categories?.map {
                CategoryBudget(category: $0, date: date, budget: self)
            } ?? []
        }

        private var previousMonthToBudget: Double {
            previousBudget.toBudget
        }

        private var availableIncome: Double {
            0.0
        }

        var availableFunds: Double {
            0.0
        }

        var overspend: Double {
            var overspend = 0.0
            for budget in budgets {
                if budget.available < 0 {
                    overspend += abs(budget.available)
                }
            }
            return overspend
        }

        var overspendInPreviousMonth: Double {
            previousBudget.overspend
        }

        var budgeted: Double {
            var budgeted = 0.0
            for budget in budgets {
                budgeted += budget.budgeted
            }
            return budgeted
        }

        var spend: Double {
            var spend = 0.0
            for budget in budgets {
                spend += budget.spend
            }
            return spend
        }

        var balance: Double {
            var balance = 0.0
            for budget in budgets {
                balance += budget.available
            }
            return balance
        }

        var toBudget: Double {
            var toBudget = availableFunds - budgeted + overspendInPreviousMonth
            if !settings.ignoreUncategorized {
                toBudget += uncategorized
            }
            return toBudget
        }
    }

    class CategoryBudget: Identifiable, ObservableObject {
        var category: Category
        @Published var budgeted: Double = 0
        @Published var spend: Double = 0
        @Published var available: Double = 0
        var id = UUID()
        private var date: Date
        private var budget: MonthlyBudget

        private var cancellableBag = Set<AnyCancellable>()

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
                DispatchQueue.main.async { [self] in
                    updateBasedOn(children: category.children)
                    category.children?.forEach { child in
                        if let childBudget = budget.budgets.first(where: { $0.category == child }) {
                            childBudget.$budgeted.sink { [weak self] _ in
                                self?.updateBasedOn(children: category.children)
                            }.store(in: &cancellableBag)
                            childBudget.$spend.sink { [weak self] _ in
                                self?.updateBasedOn(children: category.children)
                            }.store(in: &cancellableBag)
                            childBudget.$available.sink { [weak self] _ in
                                self?.updateBasedOn(children: category.children)
                            }.store(in: &cancellableBag)
                        }
                    }
                }
            } else {
                category.$transactions.sink { [weak self] transactions in
                    self?.updateBasedOn(transactions: transactions)
                }.store(in: &cancellableBag)
            }
        }

        func updateBasedOn(children: [Category]?) {
//            Self.logger.debug("Update based on children \(children?.debugDescription ?? "[]")")
            var budgeted = 0.0
            var spend = 0.0
            var available = 0.0
            children?.forEach { child in
                if let childBudget = budget.budgets.first(where: { $0.category == child }) {
                    budgeted += childBudget.budgeted
                    spend += childBudget.spend
                    available += childBudget.available
                }
            }
            self.budgeted = budgeted
            self.spend = spend
            self.available = available
        }

        func updateBasedOn(transactions: Set<Transaction>) {
            let currentMonthTransactions = transactions.filter { $0.bookingDate.sameMonthAs(date)}
//            Self.logger.notice("\(self.category.name) \(self.date.monthID) Category transactions: \(currentMonthTransactions.count)/\(transactions.count)")
            spend = currentMonthTransactions.reduce(into: 0.0) { partialResult, transaction in
                partialResult += transaction
            }
        }
    }

    struct Settings: Codable {
        var ignorePendingTransactions = true
        var startDate = Date()
        var startBalance = 0.0
        var currency = "EUR"
        var ignoreUncategorized = false
//        var incomeCategories = [IncomeCategory]()

//        struct IncomeCategory {
//            var category: Category
//            var availableIn: Int
//        }
    }
}
