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
    @State var displayedMonthIDs: [String] = [Date().previousMonth().monthID, Date().monthID, Date().nextMonth().monthID/*, Date().nextMonth().nextMonth().monthID*/]
    @State var selectedDate: String
    
    var body: some View {
        BudgetView(moneymoney: moneymoney, budget: budget, displayedMonthIDs: $displayedMonthIDs)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    MonthSelectorView(scrollTarget: $selectedDate, displayedMonthIDs: $displayedMonthIDs)
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
        ContentView(moneymoney: MoneyMoney(), budget: Budget(), selectedDate: Date().monthID)
    }
}
