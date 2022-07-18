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
    
    var body: some View {
        AccountList(accounts: moneymoney.accounts, isSelectable: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
