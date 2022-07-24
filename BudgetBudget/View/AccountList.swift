    //
    //  AccountList.swift
    //  BudgetBudget
    //
    //  Created by Leo Benz on 18.07.22.
    //

import SwiftUI

/// Hierarchical view representing a list of accounts
struct AccountList: View {
    /// List of root level accounts to show in the list
    var accounts: [Account]?
    /// If true show a checkbox to be able to select accounts
    var isSelectable = false
    
    var body: some View {
        List(accounts ?? [], children: \.children) {
            AccountRow(account: $0, isSelectable: isSelectable)
        }.listStyle(.sidebar)
    }
    
    struct AccountRow: View {
        // It is required to nest this view into a dedicated struct with an individual observed object
        // because the observed object wrapper does not update the view if it is observing an array of
        // classes.
        @ObservedObject var account: Account
        var isSelectable = false
        
        var body: some View {
            if account.isGroup || !isSelectable {
                AccountRowContent(account: account)
            } else {
                Toggle(isOn: Binding(get: {
                    account.isSelected
                }, set: {
                    account.isSelected = $0
                })) {
                    AccountRowContent(account: account)
                }
            }
        }
        
        struct AccountRowContent: View {
            @ObservedObject var account: Account
            
            var body: some View {
                HStack {
                    Image(data: account.icon)
                    Text(account.name)
                }
            }
        }
    }
}

struct AccountList_Previews: PreviewProvider {
    static var previews: some View {
        AccountList(accounts: MoneyMoney().accounts)
    }
}
