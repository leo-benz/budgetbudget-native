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
        List(categories ?? [], children: \.children) {
            CategoryRowContent(category: $0)
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
            }
        }
    }
}

struct CategoryList_Previews: PreviewProvider {
    static var previews: some View {
        CategoryList()
    }
}
