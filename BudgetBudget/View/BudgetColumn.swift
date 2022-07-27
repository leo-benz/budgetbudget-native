//
//  BudgetColumn.swift
//  BudgetBudget
//
//  Created by Leo Benz on 27.07.22.
//

import SwiftUI

struct BudgetColumn: View {
    @State private var budgeted: Double = 3.5

    var body: some View {
        VStack {
            ForEach(0..<100) {_ in
                BudgetRow(budgeted: $budgeted)
            }
        }
    }

    struct BudgetRow: View {
        @Binding var budgeted: Double

        @State private var spend = 8.5
        @State private var balance = -5.0

        @State private var hovered = false
        @FocusState private var isFocused: Bool

        var body: some View {
            HStack {
                TextField("Budgeted", value: $budgeted, format: .number)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .textFieldStyle(.plain).multilineTextAlignment(.trailing)
                    .onHover { hovered = $0 }
                    .focused($isFocused)
                    .border(isFocused ? .blue : hovered ? Color.secondary : .clear)
                Text("\(spend, specifier: "%.2f")").frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(spend == 0 ? .secondary : .primary)
                Text("\(balance, specifier: "%.2f")").frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(balance < 0 ? .red : balance == 0 ? .secondary : .primary)
            }.font(.body.monospaced())
        }
    }
}

struct BudgetColumn_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BudgetColumn()
        }.frame(width: 300)
    }
}
