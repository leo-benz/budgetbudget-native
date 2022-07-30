//
//  Account.swift
//  BudgetBudget
//
//  Created by Leo Benz on 17.07.22.
//

import Foundation
import SwiftUI

class Account: ObservableObject, Decodable, HierarchyElement, Hashable, Identifiable, CustomStringConvertible, CustomDebugStringConvertible {
    typealias Element = Account

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

    var moneymoney: MoneyMoney?

    // Custom Properties
    private (set) var children: [Account]?

    @Published var isSelected = false {
        didSet {
            if let moneymoney = moneymoney {
                moneymoney.syncTransactions()
            }
        }
    }
    
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
}

extension Account {
    func recursiveForEach(_ callback: (Account) -> Void) {
        callback(self)
        children?.forEach{ $0.recursiveForEach(callback)}
    }
}
