//
//  BudgetHeader.swift
//  BudgetBudget
//
//  Created by Leo Benz on 27.07.22.
//

import SwiftUI

struct BudgetHeader: View {
    var budget: MonthlyBudget

    var body: some View {
        VStack (spacing: 10) {
            Text(budget.date.month.description).font(.headline)

            Grid(verticalSpacing: 3) {
                GridRow(alignment: .firstTextBaseline) {
                    Text("\(budget.availableFunds, specifier: "%.2f")").font(.body.monospaced()).gridColumnAlignment(.trailing)
                    Text("Available Funds").gridColumnAlignment(.leading)
                }
                GridRow(alignment: .firstTextBaseline) {
                    Text("\(budget.overspendInPreviousMonth, specifier: "%.2f")").font(.body.monospaced())
                    Text("Overspend in \(budget.date.previousMonth().month.description)")
                }
                if (budget.uncategorized > 0) {
                    GridRow(alignment: .firstTextBaseline) {
                        Text("\(budget.uncategorized, specifier: "%.2f")").font(.body.monospaced())
                        Text("Uncategorized")

                    }
                }
                GridRow(alignment: .firstTextBaseline) {
                    Text("\(budget.budgeted, specifier: "%.2f")").font(.body.monospaced())
                    Text("Budgeted")
                }
                GridRow(alignment: .firstTextBaseline) {
                    Text("\(budget.toBudget, specifier: "%.2f")").toBudgetStyle(value: budget.toBudget, monospaced: true)
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
    static var monthlyBudget = MonthlyBudget(date: Date(), budget: Budget())

    static var previews: some View {
        BudgetHeader(budget: monthlyBudget).frame(width: 500)
    }
}
