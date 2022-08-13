//
//  Date+Month.swift
//  BudgetBudget
//
//  Created by Leo Benz on 13.08.22.
//

import Foundation

extension Date {
    init(month: Month, year: Int) {
        self.init("\(String(withInt: year, leadingZeros: 4))-\(String(withInt: month.rawValue, leadingZeros: 2))-01")
    }

    init(_ dateString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale.current
        let date = formatter.date(from: dateString)!
        self.init(timeInterval: 0, since: date)
    }

    var monthID: String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM"
        return dateformat.string(from: self)
    }

    var month: Month {
        let dateComponents = Calendar.current.dateComponents([.month], from: self)
        return Month(rawValue: dateComponents.month!)!
    }

    var year: Int {
        let dateComonents = Calendar.current.dateComponents([.year], from: self)
        return dateComonents.year!
    }

    func previousMonth() -> Date {
        return Date(month: self.month - 1, year: month == .January ? self.year - 1 : self.year)
    }

    func sameMonthAs(_ date: Date) -> Bool {
        return self.month == date.month && self.year == date.year
    }
}

public enum Month: Int {
    case January = 1, February, March, April, May, June, July, August, September, October, November, December
}

extension Month: CustomStringConvertible {
    public var description: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        let date = Date(month: self, year: 2000)
        return formatter.string(from: date)
    }
}

extension Month: Equatable { }

public func +(lhs: Month, rhs: Int) -> Month {
    let normalized = rhs % 12
    return Month(rawValue: ((lhs.rawValue + normalized + 12 - 1) % 12) + 1)!
}

public func -(lhs: Month, rhs: Int) -> Month {
    return lhs + (-rhs % 12)
}
