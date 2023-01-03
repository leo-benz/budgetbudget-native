//
//  Account.swift
//  BudgetBudget
//
//  Created by Leo Benz on 17.07.22.
//

import Foundation
import SwiftUI
import Combine
import os

class Account: SelectableListEntry, Decodable, HierarchyElement, Hashable, Identifiable, CustomStringConvertible, CustomDebugStringConvertible {
    func clearChildren() {
        children = nil
    }
    
    func update(from element: Account) {
        self.name = element.name
        self.indentation = element.indentation
        self.isPortfolio = element.isPortfolio
        self.owner = element.owner
        self.icon = element.icon
        self.isGroup = element.isGroup
        self.currency = element.currency
        self.bankCode = element.bankCode
        self.attributes = element.attributes
        self.accountNumber = element.accountNumber
        self.balance = element.balance
    }
    
    typealias Element = Account
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Account.self)
    )
    
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

    var transactions = Set<Transaction>()

    // Custom Properties
    private (set) var children: [Account]?

    @Published var isSelected = false {
        didSet {
            if let moneymoney = moneymoney {
                moneymoney.syncTransactions()
            }
            if !isSelected {
                transactions.forEach { $0.delete() }
            }
        }
    }
    
    var isSelectable: Bool {
        !isGroup && !isPortfolio
    }
    
    func append(child: Account) {
        if children == nil {
            children = []
        }
        children!.append(child)
    }
    
    private var cancellableBag: Set<AnyCancellable> = []
    
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
        
        isSelected = UserDefaults.standard.bool(forKey: "Account-\(self.id):Selected")
        $isSelected.sink { [weak self] isSelected in
            if let self = self {
                UserDefaults.standard.set(isSelected, forKey: "Account-\(self.id):Selected")
            }
        }.store(in: &cancellableBag)
    }
    
    // From MoneyMoney
    var name: String
    var indentation: Int
    let id: UUID
    var isPortfolio: Bool
    var owner: String
    var icon: Data
    var isGroup: Bool
    var currency: String
    var bankCode: String
    var attributes: [String: String]
    var accountNumber: String
    var balance: [Money]
    
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
