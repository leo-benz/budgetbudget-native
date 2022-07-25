//
//  SettingsView.swift
//  BudgetBudget
//
//  Created by Leo Benz on 19.07.22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var moneymoney: MoneyMoney

    @State private var name = ""
    @State private var currency = ""
    @State private var ignorePendingTransactions = false
    @State private var startDate = Date.now
    @State private var startingBalance: Double = 0

    var body: some View {
        TabView {
            Form {
                TextField("Name", text: $name)
                TextField("Currency", text: $currency)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                HStack(spacing: 0) {
                    Text("Starting Balance")
                    TextField("", value: $startingBalance, format: .currency(code: currency))
                        .padding(.trailing, 3.0)
                        .alignmentGuide(.controlAlignment) { $0[.leading] }
                    Stepper("Starting Balance", value: $startingBalance, step: 1).labelsHidden()
                        .padding([.trailing])
                    Button("Re-Calculate") { }
                }.alignmentGuide(.leading) { $0[.controlAlignment] }
            }.tabItem {
                Label("General", systemImage: "gear")
            }.padding(20)

            Form {
                Section("Income Categories") {

                }
            }.tabItem {
                Label("Categories", systemImage: "bookmark")
            }.padding(20)

            Form {
                Toggle("Ignore pending transactions", isOn: $ignorePendingTransactions)

                if #available(macOS 13.0, *) {
                    LabeledContent("Tracked Accounts") {
                        AccountList(accounts: moneymoney.accounts, isSelectable: true)
                            .listStyle(.bordered)
                    }
                } else {
                    AccountList(accounts: moneymoney.accounts, isSelectable: true)
                        .listStyle(.bordered)
                }
            }.tabItem {
                Label("Accounts", systemImage: "building.columns")
            }.padding(20)
        }.frame(minWidth: 350, minHeight: 150)
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
