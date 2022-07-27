//
//  BudgetView.swift
//  BudgetBudget
//
//  Created by Leo Benz on 27.07.22.
//

import SwiftUI

struct BudgetView: View {
    @ObservedObject var moneymoney: MoneyMoney

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BudgetHeader().hidden().background(VisualEffect(material: .sidebar, blendingMode: .behindWindow))
                BudgetHeader()
                BudgetHeader()
                BudgetHeader()
            }
            Divider()
            ScrollView(.vertical) {
                HStack {
                    CategoryList(categories: moneymoney.filteredCategories).background(VisualEffect(material: .sidebar, blendingMode: .behindWindow))
                    BudgetColumn().frame(maxWidth: .infinity)
                    BudgetColumn().frame(maxWidth: .infinity)
                    BudgetColumn().frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(moneymoney: MoneyMoney())
    }
}
