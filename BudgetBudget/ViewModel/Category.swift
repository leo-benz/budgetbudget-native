//
//  Category.swift
//  BudgetBudget
//
//  Created by Leo Benz on 25.07.22.
//

import Foundation
import SwiftUI

class Category: ObservableObject, Decodable, HierarchyElement, Hashable, Identifiable, CustomStringConvertible, CustomDebugStringConvertible {
    typealias Element = Category

    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }

    struct Budget: Decodable {
        let amount: Double
        let available: Double
        let period: String
    }


    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var description: String {
        name
    }

    var debugDescription: String {
        name
    }

    private (set) var children: [Category]? {
        didSet {
            children?.enumerated().forEach { $0.element.isEven = $0.offset % 2 != 0}
        }
    }

    @Published var isSelected = false
    @Published var transactions = Set<Transaction>()

    func append(child: Category) {
        if children == nil {
            children = []
        }
        children!.append(child)
    }

    let indentation: Int
    let name: String
    let id: UUID
    let icon: Data
    let currency: String
    let isDefault: Bool
    let budget: Category.Budget?
    let isGroup: Bool
    var isIncome = false
    var isEven: Bool = false

    @Published var isExpanded = true {
        didSet {
            children?.forEach { $0.isVisible = self.isExpanded }
        }
    }

    @Published var isVisible = true {
        didSet {
            children?.forEach { $0.isVisible = self.isVisible }
        }
    }

    enum CodingKeys: String, CodingKey {
        case indentation
        case name
        case id = "uuid"
        case icon
        case currency
        case isDefault = "default"
        case budget
        case isGroup = "group"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.indentation = try container.decode(Int.self, forKey: .indentation)
        self.name = try container.decode(String.self, forKey: .name)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.icon = try container.decode(Data.self, forKey: .icon)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.isDefault = try container.decode(Bool.self, forKey: .isDefault)
        self.budget = try? container.decodeIfPresent(Category.Budget.self, forKey: .budget)
        self.isGroup = try container.decode(Bool.self, forKey: .isGroup)
    }
}

extension Category {
    func recursiveForEach(_ callback: (Category) -> Void) {
        callback(self)
        children?.forEach{ $0.recursiveForEach(callback)}
    }
}

