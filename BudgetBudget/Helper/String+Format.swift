//
//  String+Format.swift
//  BudgetBudget
//
//  Created by Leo Benz on 13.08.22.
//

import Foundation

extension String {
    init(withInt int: Int, leadingZeros: Int = 0) {
        self.init(format: "%0\(leadingZeros)d", int)
    }

    func leading(zeros: Int) -> String {
        if let int = Int(self) {
            return String(withInt: int, leadingZeros: zeros)
        }
        print("Warning: \(self) is not an Int")
        return ""
    }
}
