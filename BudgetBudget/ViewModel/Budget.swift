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

    private var monthlyBudgets: [String: MonthlyBudget] = [:]
    private var subscribers: Set<AnyCancellable> = []

    init() {
        settings = UserDefaults.standard.codable(forKey: "Settings") ?? Settings()
        $settings.sink { setting in
            UserDefaults.standard.set(value: setting, forKey: "Settings")
        }.store(in: &subscribers)
    }

    func budgetFor(date: Date) -> MonthlyBudget? {
        let monthlyBudget = monthlyBudgets[date.monthID]

        if let monthlyBudget = monthlyBudget {
            return monthlyBudget
        } else {
            if date < settings.startDate {
                return nil
            } else {
                let budget = MonthlyBudget(date: date, budget: self)
                monthlyBudgets[date.monthID] = budget
                return budget
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
