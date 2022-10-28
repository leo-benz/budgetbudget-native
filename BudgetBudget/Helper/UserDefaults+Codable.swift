//
//  UserDefaults+Codable.swift
//  BudgetBudget
//
//  Created by Leo Benz on 28.10.22.
//
//  Based on https://itnext.io/adding-codable-support-to-userdefaults-with-swift-26a799bf00e1

import Foundation

extension UserDefaults {
    func set<Element: Codable>(value: Element, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        UserDefaults.standard.setValue(data, forKey: key)
    }

    func codable<Element: Codable>(forKey key: String) -> Element? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        let element = try? JSONDecoder().decode(Element.self, from: data)
        return element
    }
}
