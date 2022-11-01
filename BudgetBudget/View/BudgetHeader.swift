//
//  BudgetHeader.swift
//  BudgetBudget
//
//  Created by Leo Benz on 27.07.22.
//

import SwiftUI

struct BudgetHeader: View {
    @ObservedObject var monthBudget: MonthlyBudget
    @ObservedObject var budget: Budget
    
    init(monthBudget: MonthlyBudget) {
        self.monthBudget = monthBudget
        self.budget = monthBudget.budget
    }
    
    var body: some View {
        VStack (spacing: 5) {
            Text(monthBudget.date.month.description).font(.headline).padding([.top], 7).padding([.bottom], 3)

            Grid(verticalSpacing: 3) {
                GridRow(alignment: .firstTextBaseline) {
                    Text("\(monthBudget.availableFunds, specifier: "%.2f")").font(.body.monospaced()).gridColumnAlignment(.trailing)
                    Text("Available Funds").gridColumnAlignment(.leading)
                }
                GridRow(alignment: .firstTextBaseline) {
                    Text("\(monthBudget.overspendInPreviousMonth, specifier: "%.2f")").font(.body.monospaced())
                    Text("Overspend in \(monthBudget.date.previousMonth().month.description)")
                }
                if (monthBudget.uncategorized != 0.0 && !monthBudget.budget.settings.ignoreUncategorized) {
                    GridRow(alignment: .firstTextBaseline) {
                        Text("\(monthBudget.uncategorized, specifier: "%.2f")").font(.body.monospaced())
                        Text("Uncategorized")

                    }
                }
                GridRow(alignment: .firstTextBaseline) {
                    Text("\(monthBudget.budgeted > 0 ? "-" : "")\(monthBudget.budgeted, specifier: "%.2f")").font(.body.monospaced())
                    Text("Budgeted")
                }
                GridRow(alignment: .firstTextBaseline) {
                    Text("\(monthBudget.toBudget, specifier: "%.2f")").toBudgetStyle(value: monthBudget.toBudget, monospaced: true)
                    Text("\(monthBudget.toBudget < 0 ? "Overbudgeted" : "To Budget")").toBudgetStyle(value: monthBudget.toBudget)
                }
            }
            
            Spacer(minLength: 0)
            
            HStack {
                VStack(alignment: .trailing) {
                    Text("Budgeted").font(.subheadline).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.secondary)
                    Text("\(monthBudget.budgeted, specifier: "%.2f")").font(.headline.monospaced())
                }
                VStack(alignment: .trailing) {
                    Text("Spend").font(.subheadline).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.secondary)
                    Text("\(monthBudget.spend, specifier: "%.2f")").font(.headline.monospaced())
                }
                VStack(alignment: .trailing) {
                    Text("Balance").font(.subheadline).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.secondary)
                    Text("\(monthBudget.balance, specifier: "%.2f")").font(.headline.monospaced())
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
        BudgetHeader(monthBudget: monthlyBudget).frame(width: 500)
    }
}
