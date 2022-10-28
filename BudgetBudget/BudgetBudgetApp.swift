    //
    //  BudgetBudgetApp.swift
    //  BudgetBudget
    //
    //  Created by Leo Benz on 17.07.22.
    //

import SwiftUI

@main
struct BudgetBudgetApp: App {
    @StateObject var budget = Budget()

    var body: some Scene {
        WindowGroup {
            // SplashView()
            ContentView(moneymoney: budget.moneymoney, budget: budget).onAppear {
                budget.moneymoney.sync()
            }
        }.windowStyle(.titleBar)
            .windowToolbarStyle(.unifiedCompact)

#if os(macOS)
        Settings {
            SettingsView(moneymoney: budget.moneymoney, settings: $budget.settings)
        }
#endif
    }
}

