//
//  Budget.swift
//  BudgetBudget
//
//  Created by Leo Benz on 29.07.22.
//

import Foundation

class Budget: ObservableObject {

    var name: String = ""

    var monthlyBudgets: [Date: MonthlyBudget] = [:]

    struct MonthlyBudget {
        var date: Date
        var budgets: [CategoryBudget]
        var uncategorized: Double
        var settings: Settings

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

        var toBudget: Double {
            var toBudget = availableFunds - budgeted + overspendInPreviousMonth
            if !settings.ignoreUncategorized {
                toBudget += uncategorized
            }
            return toBudget
        }
    }

    struct CategoryBudget {
        var category: Category
        var budgeted: Double
        var spend: Double
        var available: Double
    }

    struct Settings {
        var ignorePendingTransactions: Bool
        var startDate: Date
        var startBalance: Double
        var currency: String
        var ignoreUncategorized: Bool

        struct IncomeCategory {
            var category: Category
            var availableIn: Int
        }
    }
}
