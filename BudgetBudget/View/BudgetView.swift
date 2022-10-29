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
    
    @Binding var selectedDate: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VisualEffect(material: .sidebar, blendingMode: .behindWindow).frame(width: categoryListWidth)
                Divider()
                Divider()
                BudgetHeader(budget: budget.budgetFor(date: Date(monthID: selectedDate).previousMonth())).padding(.horizontal)
                Divider()
                BudgetHeader(budget: budget.budgetFor(date: Date(monthID: selectedDate))).padding(.horizontal)
                Divider()
                BudgetHeader(budget: budget.budgetFor(date: Date(monthID: selectedDate).nextMonth())).padding(.horizontal)
            }.fixedSize(horizontal: false, vertical: true)
            Divider()
            GeometryReader { scrollGeo in
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
                        BudgetColumn(budget: budget.budgetFor(date: Date(monthID: selectedDate).previousMonth())).frame(maxWidth: .infinity).padding(.horizontal)
                        Divider()
                        BudgetColumn(budget: budget.budgetFor(date: Date(monthID: selectedDate))).frame(maxWidth: .infinity).padding(.horizontal)
                        Divider()
                        BudgetColumn(budget: budget.budgetFor(date: Date(monthID: selectedDate).nextMonth())).frame(maxWidth: .infinity).padding(.horizontal)
                    }.frame(minHeight: scrollGeo.size.height)
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
        BudgetView(moneymoney: MoneyMoney(), budget: Budget(), selectedDate: .constant("Jan2023"))
    }
}
