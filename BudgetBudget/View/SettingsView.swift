//
//  SettingsView.swift
//  BudgetBudget
//
//  Created by Leo Benz on 19.07.22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var moneymoney: MoneyMoney
    @Binding var settings: Budget.Settings
    
    @State private var name = ""

    var body: some View {
        TabView {
            Form {
                TextField("Name", text: $name)
                TextField("Currency", text: $settings.currency)
                DatePicker("Start Date", selection: $settings.startDate, in: ...Date() ,displayedComponents: .date)
                HStack(spacing: 0) {
                    Text("Starting Balance")
                    TextField("", value: $settings.startBalance, format: .currency(code: settings.currency))
                        .padding(.trailing, 3.0)
                        .alignmentGuide(.controlAlignment) { $0[.leading] }
                    Stepper("Starting Balance", value: $settings.startBalance, step: 1).labelsHidden()
                        .padding([.trailing])
//                    Button("Re-Calculate") { }
                }.alignmentGuide(.leading) { $0[.controlAlignment] }
            }.tabItem {
                Label("General", systemImage: "gear")
            }.formStyle(.grouped)

            Form {
                Toggle("Ignore uncategorized transactions", isOn: $settings.ignoreUncategorized)
                LabeledContent("Income Categories") {
                    CategorySelectableList(rootEntries: moneymoney.categories, isSelectionEnabled: true, updateCallback: { _ in
                        // TODO: This is a quick solution now to trigger a complete sync to update. There should be a cleaner and more efficient way to only update what is needed.
                        moneymoney.sync()
                    })
                        .listStyle(.bordered)
                }
            }.tabItem {
                Label("Categories", systemImage: "bookmark")
            }.formStyle(.grouped)

            Form {
                Toggle("Ignore pending transactions", isOn: $settings.ignorePendingTransactions)
                LabeledContent("Tracked Accounts") {
                    AccountSelectableList(rootEntries: moneymoney.accounts, isSelectionEnabled: true)
                        .listStyle(.bordered)
                }
            }.tabItem {
                Label("Accounts", systemImage: "building.columns")
            }.formStyle(.grouped)
        }.frame(minWidth: 350, minHeight: 350)
    }
}

extension HorizontalAlignment {
    private enum ControlAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[HorizontalAlignment.center]
        }
    }

    static let controlAlignment = HorizontalAlignment(ControlAlignment.self)
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView(moneymoney: MoneyMoney())
//    }
//}
