//
//  ContentView.swift
//  BudgetBudget
//
//  Created by Leo Benz on 17.07.22.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject var moneymoney = MoneyMoney()
    
    @State var selection: Int = 0
    
    
    var body: some View {
        AccountList(accounts: moneymoney.accounts, isSelectable: true)
            .toolbar {
                MonthSelectorView()
                ToolbarItem(placement: ToolbarItemPlacement.principal) {
                    Button("Today") {}
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
