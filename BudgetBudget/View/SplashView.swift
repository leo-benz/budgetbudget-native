//
//  SplashView.swift
//  BudgetBudget
//
//  Created by Leo Benz on 23.07.22.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            VStack {
                Text("Welcome to BudgetBudget")
                    .font(.largeTitle)
                Text("envelope-style budgeting for your MoneyMoney transactions")
                    .font(.title3)
                    .italic()
                Divider().padding([.top, .bottom])
                Text("This app is under development and not usable yet.\nPlease check back later.")
                    .multilineTextAlignment(.center)
            }
        }
        .frame(minWidth: 300, minHeight: 300)
        .background(VisualEffect(material: .underWindowBackground, blendingMode: .behindWindow))
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
