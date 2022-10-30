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
    // ---------------------
    
    @Binding var scrollTarget: String
    @Binding var displayedMonthIDs: [String]
    
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
                                            if (displayedMonthIDs.contains(id)) {
                                                Rectangle()
                                                    .fill(Color.accentColor)
                                                    .frame(height: 3.5)
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
                let targetMonth = Date(monthID: newValue)
                for i in displayedMonthIDs.indices {
                    displayedMonthIDs[i] = targetMonth.nextMonth(i-1).monthID
                }
                
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
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

struct MonthSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        MonthSelectorView(scrollTarget: .constant("Jan2023"), displayedMonthIDs: .constant([Date().previousMonth().monthID, Date().monthID, Date().nextMonth().monthID])).frame(width: 300, height: 30)
        MonthSelectorView(scrollTarget: .constant("Jan2023"), displayedMonthIDs: .constant([Date().previousMonth().monthID, Date().monthID, Date().nextMonth().monthID])).preferredColorScheme(.dark).frame(width: 300, height: 30)
    }
}
