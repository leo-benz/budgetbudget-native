//
//  VisualEffect.swift
//  BudgetBudget
//
//  Created by Leo Benz on 23.07.22.
//

import SwiftUI

#if os(OSX)
struct VisualEffect: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Self.Context) -> NSView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
#else
struct VisualEffect: View {
    var body: some View {
        EmptyView()
    }
}
#endif
