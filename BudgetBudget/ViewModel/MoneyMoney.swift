    //
    //  MoneyMoney.swift
    //  BudgetBudget
    //
    //  Created by Leo Benz on 17.07.22.
    //

import Foundation

class MoneyMoney: ObservableObject {
    
    public var installed: Bool {
#if os(OSX)
        return executeAppleScript("moneymoneyExists").booleanValue
#else
        return false
#endif
    }
    
    @Published public var accounts: [Account]!
    
    init() {
#if os(OSX)
        let accountsXML = executeAppleScript("exportAccounts").stringValue ?? ""
        let decoder = PropertyListDecoder()
        do {
            let decoded = try decoder.decode(Hierarchy<Account>.self, from: accountsXML.data(using: .utf8)!)
            accounts = decoded.rootElements
        } catch {
            fatalError("Unable to decode accounts:\(error)")
        }
#else
        accounts = []
#endif
    }
    
#if os(OSX)
    func executeAppleScript(_ name: String) -> NSAppleEventDescriptor {
        if let installedCheckerURL = Bundle.main.url(forResource: name, withExtension: "scpt") {
            if let installedCheckerScript = NSAppleScript(contentsOf: installedCheckerURL, error: nil) {
                var errorInfo = NSDictionary()
                let errorInfoPointer = AutoreleasingUnsafeMutablePointer<NSDictionary?>.init(&errorInfo)
                let results = installedCheckerScript.executeAndReturnError(errorInfoPointer)
                if errorInfo.count == 0 {
                    return results
                } else {
                    fatalError("Error during execution of \(name).scpt: \(errorInfo.description)")
                }
            } else {
                fatalError("Could not create applescript from \(installedCheckerURL)")
            }
        } else {
            fatalError("Could not find \(name).scpt in main bundle")
        }
    }
#endif
}
