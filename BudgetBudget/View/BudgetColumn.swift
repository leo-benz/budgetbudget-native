//
//  BudgetColumn.swift
//  BudgetBudget
//
//  Created by Leo Benz on 27.07.22.
//

import SwiftUI

struct BudgetColumn: View {
    @ObservedObject var budget: Budget.MonthlyBudget

    var body: some View {
        VStack(spacing: 0) {
            ForEach(budget.budgets) { budget in
                BudgetRow(categoryBudget: budget, category: budget.category)
            }
            Spacer()
        }
    }

    struct BudgetRow: View {
        @ObservedObject var categoryBudget: Budget.CategoryBudget
        @ObservedObject var category: Category

        @State private var hovered = false
        @FocusState private var isFocused: Bool

        private let numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.generatesDecimalNumbers = true
            formatter.allowsFloats = true
            formatter.alwaysShowsDecimalSeparator = true
            formatter.usesSignificantDigits = true
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter
        }()

        var body: some View {
            if category.isVisible {
                HStack {
                    if category.isGroup {
                        Text("\(categoryBudget.budgeted, specifier: "%.2f")")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(categoryBudget.budgeted == 0 ? .secondary : .primary)
                    } else {
                        // FIXME: The Textfield here is severly degrading startup performance
                        Text("\(categoryBudget.budgeted, specifier: "%.2f")")
//                        TextField("Budgeted", value: $categoryBudget.budgeted, format: .number.precision(.fractionLength(2)))
                            .frame(maxWidth: .infinity, alignment: .trailing)
//                            .textFieldStyle(.plain).multilineTextAlignment(.trailing)
//                            .onHover { hovered = $0 }
//                            .focused($isFocused)
//                            .border(isFocused ? .blue : hovered ? Color.secondary : .clear)
//                            .foregroundColor(categoryBudget.budgeted == 0 ? .secondary : .primary)
                    }
                    Text("\(categoryBudget.spend, specifier: "%.2f")")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(categoryBudget.spend == 0 ? .secondary : .primary)
                    Text("\(categoryBudget.available, specifier: "%.2f")")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(categoryBudget.available < 0 && !category.isGroup ? .red : (categoryBudget.available == 0 ? .secondary : .primary))
                }.font(category.isGroup ? .subheadline.monospaced() : .body.monospaced())
                    .padding([.vertical], 3)
                    .padding([.top], category.isGroup ? 5 : 0)
                    .padding(.horizontal)
                    // FIXME: Replace magic number with calculated value from category list
                    .frame(height: category.isGroup ? 24 : 22)
                    .background(Rectangle().foregroundColor(!category.isEven && !category.isGroup ? .secondary.opacity(0.1) : .clear))
            } else {
                EmptyView()
            }
        }
    }
}

struct BudgetColumn_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BudgetColumn(budget: Budget.MonthlyBudget(date: Date(), budget: Budget()))
        }.frame(width: 300)
    }
}
