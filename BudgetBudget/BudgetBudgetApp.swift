    //
    //  BudgetBudgetApp.swift
    //  BudgetBudget
    //
    //  Created by Leo Benz on 17.07.22.
    //

import SwiftUI

@main
struct BudgetBudgetApp: App {
    @StateObject var moneymoney = MoneyMoney()

    var body: some Scene {
        WindowGroup {
            // SplashView()
            ContentView(moneymoney: moneymoney).onAppear {
                moneymoney.sync()
            }
        }.windowStyle(.titleBar)
            .windowToolbarStyle(.unifiedCompact)

#if os(macOS)
        Settings {
            SettingsView(moneymoney: moneymoney)
        }
#endif
    }
}

