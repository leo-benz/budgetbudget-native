//
//  BudgetHeader.swift
//  BudgetBudget
//
//  Created by Leo Benz on 27.07.22.
//

import SwiftUI

struct BudgetHeader: View {
    var budget: Budget.MonthlyBudget

    var body: some View {
        VStack (spacing: 10) {
            Text(budget.date.month.description).font(.headline)
            // TODO: Use Grid in macOS 13
            HStack {
                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(budget.availableFunds, specifier: "%.2f")")
                    Text("\(budget.overspendInPreviousMonth, specifier: "%.2f")")
                    if (budget.uncategorized > 0) {
                        Text("\(budget.uncategorized, specifier: "%.2f")")
                    }
                    Text("\(budget.budgeted, specifier: "%.2f")")
                    Text("\(budget.toBudget, specifier: "%.2f")").toBudgetStyle(value: budget.toBudget, monospaced: true)
                }.font(.body.monospaced())
                VStack(alignment: .leading, spacing: 3) {
                    Text("Available Funds")
                    Text("Overspend in \(budget.date.previousMonth().month.description)")
                    if (budget.uncategorized > 0) {
                        Text("Uncategorized")
                    }
                    Text("Budgeted")
                    Text("To Budget").toBudgetStyle(value: budget.toBudget)
                }
            }

            HStack {
                VStack(alignment: .trailing) {
                    Text("Budgeted").font(.subheadline).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.secondary)
                    Text("\(budget.budgeted, specifier: "%.2f")").font(.headline.monospaced())
                }
                VStack(alignment: .trailing) {
                    Text("Spend").font(.subheadline).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.secondary)
                    Text("\(budget.spend, specifier: "%.2f")").font(.headline.monospaced())
                }
                VStack(alignment: .trailing) {
                    Text("Balance").font(.subheadline).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.secondary)
                    Text("\(budget.balance, specifier: "%.2f")").font(.headline.monospaced())
                }
            }
        }
    }
}

struct ToBudget: ViewModifier {
    var monospaced = false
    let toBudget: Double

    func body(content: Content) -> some View {
        content
            .font(toBudget == 0 ? monospaced ? .body.monospaced() : .body : monospaced ? .title.monospaced() : .title)
            .foregroundColor(toBudget < 0 ? .red : .primary)
    }
}

extension View {
    func toBudgetStyle(value: Double, monospaced: Bool = false) -> some View {
        modifier(ToBudget(monospaced: monospaced, toBudget: value))
    }
}

struct BudgetHeader_Previews: PreviewProvider {
    static var monthlyBudget = Budget.MonthlyBudget(date: Date(), budget: Budget())

    static var previews: some View {
        BudgetHeader(budget: monthlyBudget).frame(width: 500)
    }
}
