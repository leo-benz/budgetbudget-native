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
                Text("splash-welcome")
                    .font(.largeTitle)
                Text("splash-description")
                    .font(.title3)
                    .italic()
                Divider().padding([.top, .bottom])
                Text("splash-unusable")
                    
            }.multilineTextAlignment(.center)
        }
        .frame(minWidth: 300, minHeight: 300)
        #if os(macOS)
        .background(VisualEffect(material: .underWindowBackground, blendingMode: .behindWindow))
        #endif
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
        SplashView().environment(\.locale, .init(identifier: "fr"))
    }
}
