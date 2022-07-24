//
//  MonthSelectorView.swift
//  BudgetBudget
//
//  Created by Leo Benz on 24.07.22.
//

import SwiftUI


struct MonthSelectorView: View {
    static let months = Calendar.current.shortMonthSymbols
    
    // Temporary for testing
    static let years = currentYear...currentYear+10
    static let currentYear = Calendar.current.dateComponents([.year], from: Date()).year!
    static let currentMonth = months[Calendar.current.dateComponents([.month], from: Date()).month!]
    // ---------------------
    
    @Binding var scrollTarget: String?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(MonthSelectorView.years, id: \.self) { year in
                        Section {
                            ForEach(Array(zip(MonthSelectorView.months, Array(1...12).map({
                                "\(year)-\(String(format: "%02d", $0))"
                            }))) , id: \.1) { month, id  in
                                HStack(spacing: 0){
                                    Text(month)
                                        .foregroundStyle(.primary)
                                        .padding(5)
                                        .overlay(alignment: .bottom) {
                                            if (year == MonthSelectorView.currentYear && month == MonthSelectorView.currentMonth) {
                                                Rectangle()
                                                    .fill(Color.accentColor)
                                                    .frame(height: 3)
                                            }
                                        }.onTapGesture {
                                            scrollTarget = id
                                        }
                                    Divider()
                                }
                            }
                        } header: {
                            HStack(spacing: 0){
                                Text(verbatim: "\(year)")
                                    .foregroundStyle(.secondary)
                                    .padding(5)
                                Divider()
                            }.background(.regularMaterial)
                        }
                    }
                }
            }.onChange(of: scrollTarget) { newValue in
                if let newValue = newValue {
                    scrollTarget = nil
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 7.0, style: RoundedCornerStyle.continuous)
                    .strokeBorder(.secondary)
            ).clipShape(RoundedRectangle(cornerRadius: 7.0, style: RoundedCornerStyle.continuous))
                .padding([.leading, .trailing])
                .frame(maxWidth: 500)
        }
    }
}

extension Date {
    func monthID() -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM"
        return dateformat.string(from: self)
    }
}

struct MonthSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        MonthSelectorView(scrollTarget: .constant("Jan2023")).frame(width: 300, height: 30)
        MonthSelectorView(scrollTarget: .constant("Jan2023")).preferredColorScheme(.dark).frame(width: 300, height: 30)
    }
}
