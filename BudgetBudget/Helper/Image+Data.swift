    //
    //  Image+Data.swift
    //  BudgetBudget
    //
    //  Created by Leo Benz on 17.07.22.
    //
    //  Taken from: https://gist.github.com/BrentMifsud/dce3fc6a76b8ef519ea7be0a3b050674

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Image {
        /// Initializes a SwiftUI `Image` from data.
    init?(data: Data) {
#if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            self.init(uiImage: uiImage)
        } else {
            return nil
        }
#elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            self.init(nsImage: nsImage)
        } else {
            return nil
        }
#else
        return nil
#endif
    }
}
