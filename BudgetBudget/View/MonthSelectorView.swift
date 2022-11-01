//
//  MonthSelectorView.swift
//  BudgetBudget
//
//  Created by Leo Benz on 24.07.22.
//

import SwiftUI


struct MonthSelectorView: View {
    static let months = Calendar.current.shortMonthSymbols
    
    var years: ClosedRange<Int>
    var startDate: Date
    @Binding var scrollTarget: String
    @Binding var displayedMonthIDs: [String]
    
    init(startDate: Date, scrollTarget: Binding<String>, displayedMonthIDs: Binding<[String]>) {
        self.startDate = startDate
        years = startDate.year...Date().year+10
        self._scrollTarget = scrollTarget
        self._displayedMonthIDs = displayedMonthIDs
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(years, id: \.self) { year in
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
                let targetMonth = Date(newValue)
                var offset = 1
                if targetMonth.monthID == startDate.monthID {
                    offset = 0
                }
                for i in displayedMonthIDs.indices {
                    displayedMonthIDs[i] = targetMonth.nextMonth(i-offset).monthID
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
        MonthSelectorView(startDate: Date(), scrollTarget: .constant("Jan2023"), displayedMonthIDs: .constant([Date().previousMonth().monthID, Date().monthID, Date().nextMonth().monthID])).frame(width: 300, height: 30)
    }
}
