//
//  Budget.swift
//  BudgetBudget
//
//  Created by Leo Benz on 29.07.22.
//

import Foundation

class Budget: ObservableObject {

    var name: String = "Default"
    var settings = Settings()

    @Published var moneymoney = MoneyMoney()

    private var monthlyBudgets: [Date: MonthlyBudget] = [:]

    func budgetFor(date: Date) -> MonthlyBudget {
        let monthlyBudget = monthlyBudgets[date]

        if let monthlyBudget = monthlyBudget {
            return monthlyBudget
        } else {
            let budget = MonthlyBudget(date: date,
                                       budgets: moneymoney.filteredFlatCategories?.map {
                                                    CategoryBudget(category: $0, budgeted: 0, spend: 0, available: 0)
                                                } ?? [],
                                       uncategorized: 0, settings: settings)
            monthlyBudgets[date] = budget
            return budget
        }
    }

    class MonthlyBudget: ObservableObject {
        var date: Date
        @Published var budgets: [CategoryBudget]
        var uncategorized: Double
        var settings: Settings

        init(date: Date, budgets: [CategoryBudget], uncategorized: Double, settings: Settings) {
            self.date = date
            self.budgets = budgets
            self.uncategorized = uncategorized
            self.settings = settings
        }

        private var previousMonthToBudget: Double {
            0.0
        }

        private var availableIncome: Double {
            0.0
        }

        var availableFunds: Double {
            0.0
        }

        var overspendInPreviousMonth: Double {
            0.0
        }

        var budgeted: Double {
            var budgeted = 0.0
            for budget in budgets {
                budgeted += budget.budgeted
            }
            return budgeted
        }

        var spend: Double {
            0.0
        }

        var balance: Double {
            50000.0
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
        var budgeted: Double
        var spend: Double
        var available: Double
        var id = UUID()

        init(category: Category, budgeted: Double, spend: Double, available: Double, id: UUID = UUID()) {
            self.category = category
            self.budgeted = budgeted
            self.spend = spend
            self.available = available
            self.id = id
        }
    }

    class Settings {
        var ignorePendingTransactions = true
        var startDate = Date()
        var startBalance = 0
        var currency = "EUR"
        var ignoreUncategorized = false
        var incomeCategories = [IncomeCategory]()

        struct IncomeCategory {
            var category: Category
            var availableIn: Int
        }
    }
}
