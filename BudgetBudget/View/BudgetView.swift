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
    
    @Binding var displayedMonthIDs: [String]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VisualEffect(material: .sidebar, blendingMode: .behindWindow).frame(width: categoryListWidth)
                Divider()
                ForEach(displayedMonthIDs, id: \.self) { monthID in
                    Divider()
                    BudgetHeader(budget: budget.budgetFor(date: Date(monthID: monthID))!).padding(.horizontal)
                }
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
                        ForEach(displayedMonthIDs, id: \.self) { monthID in
                            Divider()
                            BudgetColumn(budget: budget.budgetFor(date: Date(monthID: monthID))!).frame(maxWidth: .infinity)
                        }
                    }
                    .frame(minHeight: scrollGeo.size.height)
                    .onChange(of: scrollGeo.size) { newSize in
                        let colCount = displayedMonthIDs.count
                        let newWidth = Int(newSize.width)

                        if (newWidth / colCount) < 325 && colCount > 1 {
                            _ = displayedMonthIDs.popLast()
                        } else if (newWidth / (colCount + 1)) > 325 {
                            if let lastMonth = displayedMonthIDs.last {
                                let newMonth = Date(monthID: lastMonth).nextMonth()
                                displayedMonthIDs.append(newMonth.monthID)
                            }
                        }
                    }
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
        BudgetView(moneymoney: MoneyMoney(), budget: Budget(), displayedMonthIDs: .constant([Date().previousMonth().monthID, Date().monthID, Date().nextMonth().monthID]))
    }
}
