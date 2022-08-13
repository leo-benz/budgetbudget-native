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

    @State private var categoryListWidth: CGFloat = 200

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VisualEffect(material: .sidebar, blendingMode: .behindWindow).frame(width: categoryListWidth)
                Divider()
                Divider()
                BudgetHeader(budget: budget.budgetFor(date: Date(month: .July, year: 2022)))
                Divider()
                BudgetHeader(budget: budget.budgetFor(date: Date(month: .August, year: 2022)))
                Divider()
                BudgetHeader(budget: budget.budgetFor(date: Date(month: .September, year: 2022)))
            }.fixedSize(horizontal: false, vertical: true)
            Divider()
            ScrollView(.vertical) {
                HStack(spacing: 0) {
                    CategoryList(categories: moneymoney.filteredCategories)
                        .background(VisualEffect(material: .sidebar, blendingMode: .behindWindow))
                        .fixedSize(horizontal: true, vertical: false)
                        .overlay(WidthGeometry())
                    // FIXME: Animation is not perfectly synchronized
                        .onPreferenceChange(WidthPreferenceKey.self) { prefKey in withAnimation {categoryListWidth = prefKey }}
                    Divider()
                    Divider()
                    BudgetColumn(budget: budget.budgetFor(date: Date(month: .July, year: 2022))).frame(maxWidth: .infinity)
                    Divider()
                    BudgetColumn(budget: budget.budgetFor(date: Date(month: .August, year: 2022))).frame(maxWidth: .infinity)
                    Divider()
                    BudgetColumn(budget: budget.budgetFor(date: Date(month: .September, year: 2022))).frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct WidthGeometry: View {
    var body: some View {
        GeometryReader { geo in
            Rectangle().fill(Color.clear).preference(key: WidthPreferenceKey.self, value: geo.size.width)
        }
    }
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat(200)

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }

    typealias Value = CGFloat
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(moneymoney: MoneyMoney(), budget: Budget())
    }
}
