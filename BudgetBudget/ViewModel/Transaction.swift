//
//  Transaction.swift
//  BudgetBudget
//
//  Created by Leo Benz on 29.07.22.
//

import Foundation

struct TransactionWrapper: Decodable {
    var creator: String
    var transactions: [Transaction]
}

public class Transaction: ObservableObject, Decodable, Identifiable, Hashable {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    private var accountId: UUID
    var account: Account? {
        willSet {
            if account != newValue {
                account?.transactions.remove(self)
            }
        }
        didSet {
            if let account = account {
                account.transactions.insert(self)
            }
        }
    }
    var amount: Double
    var booked: Bool
    var bookingDate: Date
    private var categoryId: UUID
    var category: Category? {
        willSet {
            if category != newValue {
                category?.transactions.remove(self)
            }
        }
        didSet {
            if let category = category {
                category.transactions.insert(self)
            }
        }
    }
    var checkmark: Bool
    var currency: String
    public var id: Int
    var name: String
    var valueDate: Date

    var moneymoney: MoneyMoney? {
        didSet {
            if let moneymoney = moneymoney {
                account = moneymoney.flatAccounts?.first { $0.id == accountId }
                category = moneymoney.flatCategories?.first { $0.id == categoryId }
            }
        }
    }

    func delete() {
        account = nil
        category = nil
    }

    enum CodingKeys: String, CodingKey {
        case accountId = "accountUuid"
        case amount
        case booked
        case bookingDate
        case categoryId = "categoryUuid"
        case checkmark
        case currency
        case id
        case name
        case valueDate
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accountId = try container.decode(UUID.self, forKey: .accountId)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.booked = try container.decode(Bool.self, forKey: .booked)
        self.bookingDate = try container.decode(Date.self, forKey: .bookingDate)
        self.categoryId = try container.decode(UUID.self, forKey: .categoryId)
        self.checkmark = try container.decode(Bool.self, forKey: .checkmark)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.valueDate = try container.decode(Date.self, forKey: .valueDate)
    }
}

public func +(lhs: Transaction, rhs: Transaction) -> Double {
    return lhs.amount + rhs.amount
}

public func +(lhs: Double, rhs: Transaction) -> Double {
    return lhs + rhs.amount
}

public func +=(lhs: inout Double, rhs: Transaction) {
    lhs = lhs + rhs.amount
}
