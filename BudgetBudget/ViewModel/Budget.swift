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
    @Published var moneymoney: MoneyMoney!

    private var monthlyBudgets: [String: MonthlyBudget] = [:]
    private var subscribers: Set<AnyCancellable> = []

    init() {
        settings = UserDefaults.standard.codable(forKey: "Settings") ?? Settings()
        print("Init settings: \(settings)")
        moneymoney = MoneyMoney(settings: settings)
        $settings.sink { [self] settings in
            print("Settings sink: \(settings)")
            UserDefaults.standard.set(value: settings, forKey: "Settings")
            moneymoney.settings = settings
            DispatchQueue.main.async {
                moneymoney.syncTransactions()
            }
        }.store(in: &subscribers)
    }

    func budgetFor(date: Date) -> MonthlyBudget? {
        let monthlyBudget = monthlyBudgets[date.monthID]

        if let monthlyBudget = monthlyBudget {
            return monthlyBudget
        } else {
            // Comparing date directly sometimes failes due to time stored in the date
            if date.year < settings.startDate.year || (date.year == settings.startDate.year && date.month < settings.startDate.month) {
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
        var startDate = Date().previousMonth()
        var startBalance = 0.0
        var currency = "EUR"
        var ignoreUncategorized = false
    }
}
