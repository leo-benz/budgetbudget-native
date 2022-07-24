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
    
    @State var selectedDate: String?
    
    var body: some View {
        AccountList(accounts: moneymoney.accounts, isSelectable: true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    MonthSelectorView(scrollTarget: $selectedDate)
                }
                ToolbarItem(placement: .principal) {
                    Button("Today") {
                        selectedDate = Date().monthID()
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(moneymoney: MoneyMoney())
    }
}
