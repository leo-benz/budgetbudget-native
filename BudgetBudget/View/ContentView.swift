//
//  ContentView.swift
//  BudgetBudget
//
//  Created by Leo Benz on 17.07.22.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @ObservedObject var moneymoney: MoneyMoney
    @ObservedObject var budget: Budget

    // Ordered Set would be better (no duplication), but is not in std.
    // Could use https://github.com/apple/swift-collections/blob/main/Documentation/OrderedSet.md
    @State var displayedMonthIDs: [String] = [Date().monthID]// = [Date().previousMonth().monthID, Date().monthID, Date().nextMonth().monthID/*, Date().nextMonth().nextMonth().monthID*/]
    @State var selectedDate: String
    
    init(moneymoney: MoneyMoney, budget: Budget, selectedDate: String) {
        self.moneymoney = moneymoney
        self.budget = budget
        self.selectedDate = selectedDate
        let initialDate = budget.settings.startDate < Date().previousMonth() ? Date().previousMonth() : budget.settings.startDate
        displayedMonthIDs = [initialDate.monthID, initialDate.nextMonth().monthID, initialDate.nextMonth(2).monthID]
    }
    
    var body: some View {
        BudgetView(moneymoney: moneymoney, budget: budget, displayedMonthIDs: $displayedMonthIDs)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    MonthSelectorView(startDate: budget.settings.startDate, scrollTarget: $selectedDate, displayedMonthIDs: $displayedMonthIDs)
                }
                ToolbarItem(placement: .principal) {
                    Button("Today") {
                        selectedDate = Date().monthID
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(moneymoney: MoneyMoney(settings: Budget.Settings()), budget: Budget(), selectedDate: Date().monthID)
    }
}
