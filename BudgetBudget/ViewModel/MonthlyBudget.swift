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
    var uncategorized: Double
    var budget: Budget
    private var moneymoney: MoneyMoney
    private var settings: Budget.Settings
    
    private var cancellableBag = Set<AnyCancellable>()
    
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
        self.settings = budget.settings
        self.moneymoney = budget.moneymoney
        
        // Must be async because somehow the events get messed up due to the nested recursive initialization of previous months
        DispatchQueue.main.async { [self] in
            moneymoney.$flatCategories.map { categories in
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
    }
    
    private var previousMonthToBudget: Double {
        previousBudget?.toBudget ?? 0
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
        previousBudget?.overspend ?? 0
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
            if !budget.category.isGroup {
                spend += budget.spend
            }
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
