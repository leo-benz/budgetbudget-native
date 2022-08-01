//
//  BudgetView.swift
//  BudgetBudget
//
//  Created by Leo Benz on 27.07.22.
//

import SwiftUI

struct BudgetView: View {
    @ObservedObject var moneymoney: MoneyMoney
    @ObservedObject var budget: Budget

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                BudgetHeader(budget: budget.budgetFor(date: Date())).hidden().background(VisualEffect(material: .sidebar, blendingMode: .behindWindow))
                Divider()
                Divider()
                BudgetHeader(budget: budget.budgetFor(date: Date()))
                Divider()
                BudgetHeader(budget: budget.budgetFor(date: Date()))
                Divider()
                BudgetHeader(budget: budget.budgetFor(date: Date()))
            }.fixedSize(horizontal: false, vertical: true)
            Divider()
            ScrollView(.vertical) {
                HStack(spacing: 0) {
                    CategoryList(categories: moneymoney.filteredCategories).background(VisualEffect(material: .sidebar, blendingMode: .behindWindow))
                    Divider()
                    Divider()
                    BudgetColumn(budget: budget.budgetFor(date: Date())).frame(maxWidth: .infinity)
                    Divider()
                    BudgetColumn(budget: budget.budgetFor(date: Date())).frame(maxWidth: .infinity)
                    Divider()
                    BudgetColumn(budget: budget.budgetFor(date: Date())).frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(moneymoney: MoneyMoney(), budget: Budget())
    }
}
