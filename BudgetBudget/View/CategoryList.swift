//
//  CategoryList.swift
//  BudgetBudget
//
//  Created by Leo Benz on 25.07.22.
//

import SwiftUI

struct CategoryList: View {
    var categories: [Category]?

    var body: some View {
        if let categories = categories {
            VStack {
                ForEach(categories) {
                    CategoryRow(category: $0)
                }
                Spacer()
            }
        }
    }

    struct CategoryRowContent: View {
        @ObservedObject var category: Category

        var body: some View {
            HStack {
                if !category.isGroup {
                    Image(data: category.icon)
                }
                Text(category.name)
                    .font(category.isGroup ? .caption.weight(.bold) : .body)
                Spacer()
            }.padding([.leading], CGFloat(category.indentation) * 15)
            // Can be improved for iOS16 based on custom DiscolusreGroupStyle
                .background(Rectangle().foregroundColor(category.isEven && !category.isGroup ? .secondary.opacity(0.1) : .clear))
        }
    }

    struct CategoryRow: View {
        @ObservedObject var category: Category

        var body: some View {
            if category.isGroup {
                CategoryGroup(category: category)
            } else {
                CategoryRowContent(category: category)
            }
        }
    }

    struct CategoryGroup: View {
        @ObservedObject var category: Category

        var body: some View {
            DisclosureGroup(isExpanded: $category.isExpanded) {
                ForEach(category.children!) {
                    CategoryRow(category: $0)
                }
            } label: {
                CategoryRowContent(category: category)
            }
        }
    }
}


struct CategoryList_Previews: PreviewProvider {
    static var moneymoney = MoneyMoney()

    static var previews: some View {
        CategoryList(categories: moneymoney.categories).onAppear {
            moneymoney.sync()
        }.frame(width: 300, height: 500)
    }
}
