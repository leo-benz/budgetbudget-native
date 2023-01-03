//
//  SelectableSettingsList.swift
//  BudgetBudget
//
//  Created by Leo Benz on 18.07.22.
//

import SwiftUI

// FIXME: Hacky workaround because generics is not working (see commented code below)
struct AccountSelectableList: View {
    var rootEntries: [Account]?
    var isSelectionEnabled = false
    
    var body: some View {
        List(rootEntries ?? [], children: \.children) {
            ListRow(entry: $0, isSelectionEnabled: isSelectionEnabled)
        }
    }
}

// FIXME: Hacky workaround because generics is not working (see commented code below)
struct CategorySelectableList: View {
    var rootEntries: [Category]?
    var isSelectionEnabled = false
    var updateCallback: (Bool) -> () = { _ in }

    var body: some View {
        List(rootEntries?.filter{ !$0.isDefault } ?? [], children: \.children) {
            ListRow(entry: $0, isSelectionEnabled: isSelectionEnabled, updateCallback: updateCallback)
        }
    }
}

///// Hierarchical view representing a list of accounts
//struct SelectableSettingsList<Entry: HierarchyElement & SelectableListEntry>: View {
//    /// List of root level accounts to show in the list
//    var rootEntries: [Entry]?
//    /// If true show a checkbox to be able to select accounts
//    var isSelectable = false
//
//    // Failed to produce diagnostic for expression; please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the project
//    var body: some View {
//        List(rootEntries ?? [], children: \.children) {
//            ListRow(entry: $0, isSelectable: isSelectable)
//        }
//    }
//}

struct ListRow<Entry: SelectableListEntry>: View {
    // It is required to nest this view into a dedicated struct with an individual observed object
    // because the observed object wrapper does not update the view if it is observing an array of
    // classes.
    @ObservedObject var entry: Entry
    var isSelectionEnabled = false
    var updateCallback: (Bool) -> () = { _ in }

    var body: some View {
        //            if entry.isGroup || entry.isPortfolio || !isSelectable {
        if !entry.isSelectable || !isSelectionEnabled {
            ListRowContent(entry: entry)
        } else {
            Toggle(isOn: $entry.isSelected) {
                ListRowContent(entry: entry)
            }.onChange(of: entry.isSelected, perform: updateCallback)
        }
    }
    
    struct ListRowContent<Entry: SelectableListEntry>: View {
        @ObservedObject var entry: Entry
        
        var body: some View {
            HStack {
                Image(data: entry.icon)
                Text(entry.name)
            }
        }
    }
}

protocol SelectableListEntry: ObservableObject, Identifiable {
    var isSelected: Bool { get set }
    var icon: Data { get }
    var name: String { get }
    var isSelectable: Bool { get }
}


//struct SelectableSettingsList_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectableSettingsList(rootEntries: MoneyMoney().accounts)
//    }
//}
