//
//  MonthSelectorView.swift
//  BudgetBudget
//
//  Created by Leo Benz on 24.07.22.
//

import SwiftUI

struct MonthSelectorView: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: ToolbarItemPlacement.principal) {
            HStack(spacing: 0) {
                Group{
                    Text("2021").foregroundColor(.secondary).padding(5)
                    Divider()
                    Text("Jan").padding(5)
                    Divider()
                    Text("Feb").padding(5)
                    Divider()
                    Text("Mar").padding(5)
                    Divider()
                    Text("Apr").padding(5)
                    Divider()
                }
                Group {
                    Text("May").padding(5)
                    Divider()
                    Text("Jun").padding(5)
                    Divider()
                    Text("Jul").padding(5)
                    Divider()
                    Text("Aug").padding(5).overlay(alignment: .bottom) {
                        Rectangle().fill(.blue).frame(height: 2)
                    }
                    Divider()
                    Text("Sep").padding(5)
                }
            }
            .padding([.leading, .trailing],3)
            .background(
                RoundedRectangle(cornerRadius: 7.0).strokeBorder(.secondary)
            ).padding([.leading, .trailing])
        }
    }
}

struct MonthSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle().frame(width: 300, height: 300)
        }.toolbar {
            MonthSelectorView()
        }
    }
}
