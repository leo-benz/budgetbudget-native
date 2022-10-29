//
//  BudgetBudgetCommands.swift
//  BudgetBudget
//
//  Created by Leo Benz on 29.10.22.
//

import SwiftUI

struct BudgetBudgetCommands: Commands {
    let budget: Budget
    
    var body: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.newItem) { }
        CommandGroup(replacing: .importExport) {
            Button("MoneyMoney Sync") {
                budget.moneymoney.sync()
            }.keyboardShortcut("r", modifiers: .command)
        }
    }
}
