//
//  VisualEffect.swift
//  BudgetBudget
//
//  Created by Leo Benz on 23.07.22.
//

import SwiftUI

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
