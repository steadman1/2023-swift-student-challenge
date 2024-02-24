//
//  OverlayButton.swift
//  Challenge
//
//  Created by Spencer Steadman on 4/2/23.
//

import SwiftUI

struct OverlayButton<Content: View>: View {
    let action: () -> Void
    let label: Content
    let size = 60.0
    
    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Content) {
        self.action = action
        self.label = label()
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                label
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
            }.frame(width: size, height: size)
        }.frame(width: size, height: size)
            .background(.ultraThinMaterial)
            .cornerRadius(Screen.cornerRadius)
    }
}
