    //
    //  Account.swift
    //  BudgetBudget
    //
    //  Created by Leo Benz on 17.07.22.
    //

import Foundation
import SwiftUI

class Account: ObservableObject, HierarchyElement, Hashable, Identifiable, CustomStringConvertible, CustomDebugStringConvertible {
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    struct Money: Decodable, Hashable {
        let amount: Double
        let currency: String
        
        enum CodingKeys: CodingKey {
            case amount
            case currency
        }
        
        init(from decoder: Decoder) throws {
            var container: UnkeyedDecodingContainer = try decoder.unkeyedContainer()
            self.amount = try container.decode(Double.self)
            self.currency = try container.decode(String.self)
        }
    }
    
    var description: String {
        name
    }
    
    var debugDescription: String {
        name
    }
    
        // Custom Properties
    private (set) var children: [Account]?
    @Published var isSelected = false
    
    func append(child: Account) {
        if children == nil {
            children = []
        }
        children!.append(child)
    }
    
        // From MoneyMoney
    let name: String
    let indentation: Int
    let id: UUID
    let isPortfolio: Bool
    let owner: String
    let icon: Data
    let isGroup: Bool
    let currency: String
    let bankCode: String
    let attributes: [String: String]
    let accountNumber: String
    let balance: [Money]
    
    enum CodingKeys: String, CodingKey {
        case name
        case indentation
        case id = "uuid"
        case isPortfolio = "portfolio"
        case owner
        case icon
        case isGroup = "group"
        case currency
        case bankCode
        case attributes
        case accountNumber
        case balance
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.indentation = try container.decode(Int.self, forKey: .indentation)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.isPortfolio = try container.decode(Bool.self, forKey: .isPortfolio)
        self.owner = try container.decode(String.self, forKey: .owner)
        self.icon = try container.decode(Data.self, forKey: .icon)
        self.isGroup = try container.decode(Bool.self, forKey: .isGroup)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.bankCode = try container.decode(String.self, forKey: .bankCode)
        self.attributes = try container.decode([String : String].self, forKey: .attributes)
        self.accountNumber = try container.decode(String.self, forKey: .accountNumber)
        self.balance = try container.decode([Account.Money].self, forKey: .balance)
    }
}
