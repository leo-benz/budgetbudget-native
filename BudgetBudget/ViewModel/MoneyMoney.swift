//
//  MoneyMoney.swift
//  BudgetBudget
//
//  Created by Leo Benz on 17.07.22.
//

import Foundation
import os.signpost

#if os(OSX)
import Carbon
#endif

class MoneyMoney: ObservableObject {

    private static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: MoneyMoney.self))
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MoneyMoney.self)
    )
    
    public var installed: Bool {
#if os(OSX)
        return executeAppleScript("moneymoneyExists").booleanValue
#else
        return false
#endif
    }
    
    private var transactionWrappers = [Account: TransactionWrapper]()
    
    private var accountHierarchy = Hierarchy<Account>()
    @Published public var accounts: [Account]?
    @Published public var flatAccounts: [Account]? {
        didSet {
            if let flatAccounts = flatAccounts {
                flatAccounts.forEach {
                    $0.recursiveForEach {
                        $0.moneymoney = self
                    }
                }
            }
        }
    }
    
    private var categoryHierarchy = Hierarchy<Category>()
    @Published public var categories: [Category]? {
        didSet {
            categories?.enumerated().forEach{ $0.element.isEven = $0.offset % 2 != 0}
        }
    }
    @Published public var flatCategories: [Category]?

    static func filtered(categories: [Category]) -> [Category] {
        return categories.filter {
            !$0.isDefault && !$0.isIncome
        }
    }
    
    public var filteredFlatCategories: [Category]? {
        flatCategories?.filter {
            !$0.isDefault && !$0.isIncome
        }
    }

    init() {

    }

    public func sync() {
#if os(OSX)
        Self.logger.notice("Trigger sync")
        os_signpost(.begin, log: Self.log, name: "Sync")
        let accountsXML = executeAppleScript("exportAccounts").stringValue ?? ""
        let decoder = PropertyListDecoder()
        do {
            try decoder.update(&accountHierarchy, from: accountsXML.data(using: .utf8)!)
            Self.logger.notice("Received \(self.accountHierarchy.flatElements.count, privacy: .public) Accounts: \(self.accountHierarchy.flatElements)")
            accounts = accountHierarchy.rootElements
            flatAccounts = accountHierarchy.flatElements
        } catch {
            fatalError("Unable to decode accounts: \(error)")
        }
        let categoriesXML = executeAppleScript("exportCategories").stringValue ?? ""
        do {
            try decoder.update(&categoryHierarchy, from: categoriesXML.data(using: .utf8)!)
            Self.logger.notice("Received \(self.categoryHierarchy.flatElements.count, privacy: .public) Categories: \(self.categoryHierarchy.flatElements)")
            categories = categoryHierarchy.rootElements
            flatCategories = categoryHierarchy.flatElements
        } catch {
            fatalError("Unable to decode categories: \(error)")
        }
        syncTransactions()
        os_signpost(.end, log: Self.log, name: "Sync")

#else
        accounts = []
#endif
    }

    func syncTransactions() {
#if os(OSX)
        os_signpost(.begin, log: Self.log, name: "Sync Transactions")
        let decoder = PropertyListDecoder()
        let selectedAccounts = flatAccounts!.filter{
            return $0.isSelected
        }
        Self.logger.notice("Sync Transactions for \(selectedAccounts)")
        for account in selectedAccounts {
            // TODO: Replace with start date defined in budget settings
            let transactionsXML = executeAppleScript("exportTransactions", handler: "exportTransactions", parameters: [account.name, "2022-01-01"]).stringValue!
            do {
                if transactionWrappers[account] == nil {
                    transactionWrappers[account] = TransactionWrapper(creator: "", transactions: [])
                }
                try decoder.update(&transactionWrappers[account]!, from: transactionsXML.data(using: .utf8)!)
                transactionWrappers[account]!.transactions.forEach { $0.moneymoney = self }
                Self.logger.notice("Received \(self.transactionWrappers[account]!.transactions.count, privacy: .public) Transaction for account \(account.name)")
            } catch {
                fatalError("Unable to decode transactions: \(error)")
            }
        }
        os_signpost(.end, log: Self.log, name: "Sync Transactions")
#endif
    }

#if os(OSX)
    func executeAppleScript(_ name: String) -> NSAppleEventDescriptor {
        if let scriptURL = Bundle.main.url(forResource: name, withExtension: "scpt") {
            if let script = NSAppleScript(contentsOf: scriptURL, error: nil) {
                var errorInfo = NSDictionary()
                let errorInfoPointer = AutoreleasingUnsafeMutablePointer<NSDictionary?>.init(&errorInfo)
                let results = script.executeAndReturnError(errorInfoPointer)
                if errorInfo.count == 0 {
                    return results
                } else {
                    fatalError("Error during execution of \(name).scpt: \(errorInfo.description)")
                }
            } else {
                fatalError("Could not create applescript from \(scriptURL)")
            }
        } else {
            fatalError("Could not find \(name).scpt in main bundle")
        }
    }

    func executeAppleScript(_ name: String, handler handlerString: String, parameters parameterStrings: [String]) -> NSAppleEventDescriptor {
        if let scriptURL = Bundle.main.url(forResource: name, withExtension: "scpt") {
            if let script = NSAppleScript(contentsOf: scriptURL, error: nil) {
                var errorInfo = NSDictionary()
                let errorInfoPointer = AutoreleasingUnsafeMutablePointer<NSDictionary?>.init(&errorInfo)
                let handler = NSAppleEventDescriptor(string: handlerString)
                let parameterDescriptors: [NSAppleEventDescriptor] = parameterStrings.map{NSAppleEventDescriptor(string: $0)}
                let parameters = NSAppleEventDescriptor.list()
                parameterDescriptors.forEach{parameters.insert($0, at:0)} // At 0 results in append (see documentation)
                let event = NSAppleEventDescriptor(
                    eventClass: AEEventClass(kASAppleScriptSuite),
                    eventID: AEEventID(kASSubroutineEvent),
                    targetDescriptor: nil,
                    returnID: AEReturnID(kAutoGenerateReturnID),
                    transactionID: AETransactionID(kAnyTransactionID))
                event.setDescriptor(handler, forKeyword: AEKeyword(keyASSubroutineName))
                event.setParam(parameters, forKeyword: AEKeyword(keyDirectObject))
                let results = script.executeAppleEvent(event, error: errorInfoPointer)
                if errorInfo.count == 0 {
                    return results
                } else {
                    fatalError("Error during execution of \(name).scpt: \(errorInfo.description)")
                }
            } else {
                fatalError("Could not create applescript from \(scriptURL)")
            }
        } else {
            fatalError("Could not find \(name).scpt in main bundle")
        }
    }
#endif
}
