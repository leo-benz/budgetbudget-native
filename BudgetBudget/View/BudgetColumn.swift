//
//  BudgetColumn.swift
//  BudgetBudget
//
//  Created by Leo Benz on 27.07.22.
//

import SwiftUI

struct BudgetColumn: View {
    @ObservedObject var monthlyBudget: MonthlyBudget

    @Binding var editingColumn: String
    @State private var isEditing: Bool = false
    @FocusState private var focusedCategory: UUID?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(monthlyBudget.budgets) { budget in
                BudgetRow(categoryBudget: budget, category: budget.category, focusedCategory: _focusedCategory, editing: $isEditing, focusNextCategory: { currentCategory in
                    let currentIndex = monthlyBudget.budgets.firstIndex(of: currentCategory)
                    guard var currentIndex = currentIndex else {
                        return
                    }
                    repeat {
                        currentIndex = (currentIndex + 1) % monthlyBudget.budgets.count
                    } while (!monthlyBudget.budgets[currentIndex].category.isVisible || monthlyBudget.budgets[currentIndex].category.isGroup)
                    focusedCategory = monthlyBudget.budgets[currentIndex].category.id
                })
                    .onChange(of: isEditing) { newValue in
                        if newValue {
                            editingColumn = monthlyBudget.date.monthID
                        }
                    }
                    .onChange(of: editingColumn) { newValue in
                        isEditing = (newValue == monthlyBudget.date.monthID)
                    }
            }
            Spacer()
        }.focusSection()
    }

    struct BudgetRow: View {
        @ObservedObject var categoryBudget: CategoryBudget
        @ObservedObject var category: Category

        @State private var hovered = false
        @FocusState var focusedCategory: UUID?
        @Binding var editing: Bool
        
        var focusNextCategory: (CategoryBudget) -> ()
        
        var isFocused: Bool {
            focusedCategory == category.id
        }
        
        private let numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.generatesDecimalNumbers = true
            formatter.allowsFloats = true
            formatter.alwaysShowsDecimalSeparator = true
            formatter.usesSignificantDigits = true
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter
        }()

        var body: some View {
            if category.isVisible {
                HStack {
                    if category.isGroup {
                        Text("\(categoryBudget.budgeted, specifier: "%.2f")")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(categoryBudget.budgeted == 0 ? .secondary : .primary)
                    } else {
                        // FIXME: Ugly hack with bad UX to only generate TextField on press of the Text
                        if (editing) {
                            TextField("Budgeted", value: $categoryBudget.budgeted, format: .number.precision(.fractionLength(2)))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .textFieldStyle(.plain).multilineTextAlignment(.trailing)
                                .onHover { hovered = $0 }
                                .focused($focusedCategory, equals: category.id)
                                .border(isFocused ? .blue : hovered ? Color.secondary : .clear)
                                .foregroundColor(categoryBudget.budgeted == 0 ? .secondary : .primary)
                                .onSubmit {
                                    focusNextCategory(categoryBudget)
                                }
                        } else {
                            Button {
                                editing = true
                                focusedCategory = category.id
                            } label: {
                                Text("\(categoryBudget.budgeted, specifier: "%.2f")")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .onHover { hovered = $0 }
                                    .focused($focusedCategory, equals: category.id)
                                    .border(isFocused ? .blue : hovered ? Color.secondary : .clear)
                                    .foregroundColor(categoryBudget.budgeted == 0 ? .secondary : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Text("\(categoryBudget.spend, specifier: "%.2f")")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(categoryBudget.spend == 0 ? .secondary : .primary)
                    Text("\(categoryBudget.available, specifier: "%.2f")")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(categoryBudget.available < 0 && !category.isGroup ? .red : (categoryBudget.available == 0 ? .secondary : .primary))
                }.font(category.isGroup ? .subheadline.monospaced() : .body.monospaced())
                    .padding([.vertical], 3)
                    .padding([.top], category.isGroup ? 5 : 0)
                    .padding(.horizontal)
                    // FIXME: Replace magic number with calculated value from category list
                    .frame(height: category.isGroup ? 24 : 22)
                    .background(Rectangle().foregroundColor(!category.isEven && !category.isGroup ? .secondary.opacity(0.1) : .clear))
            } else {
                EmptyView()
            }
        }
    }
}

struct BudgetColumn_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BudgetColumn(monthlyBudget: MonthlyBudget(date: Date(), budget: Budget()), editingColumn: .constant(Date().monthID))
        }.frame(width: 300)
    }
}
