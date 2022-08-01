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

class Transaction: ObservableObject, Decodable, Identifiable {
    private var accountId: UUID
    var account: Account?
    var amount: Double
    var booked: Bool
    var bookingDate: Date
    private var categoryId: UUID
    var category: Category? {
        didSet {
            if let category = category {
                category.transactions.append(self)
            }
        }
    }
    var checkmark: Bool
    var currency: String
    var id: Int
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

    required init(from decoder: Decoder) throws {
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
