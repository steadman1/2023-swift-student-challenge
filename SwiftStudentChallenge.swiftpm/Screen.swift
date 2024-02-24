//
//  Screen.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/26/22.
//

import SwiftUI
import UIKit

class Screen: ObservableObject {
    @ObservedObject static var shared = Screen()
    @Published var safeAreaInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    @Published var width = UIScreen.main.bounds.size.width
    @Published var halfWidth = UIScreen.main.bounds.size.width / 2
    static var widthToLargestIPhone: Double {
        let LARGEST_IPHONE_WIDTH = 393.0
        return Screen.shared.width > LARGEST_IPHONE_WIDTH ? LARGEST_IPHONE_WIDTH : Screen.shared.width - Screen.padding * 2
    }
    @Published var height = UIScreen.main.bounds.size.height
    @Published var halfHeight = UIScreen.main.bounds.size.height / 2
    static let size = UIScreen.main.bounds.size
    static let padding = 15.0
    static let doublePadding = 30.0
    static let cornerRadius = 18.0
    
    static func impact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func rollingImpact(n: Int = 0) {
        let impacts: [UIImpactFeedbackGenerator.FeedbackStyle] = [
            .rigid,
            .heavy,
            .medium,
            .light,
            .soft
        ]
        
        if n == impacts.count {
            return
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                UIImpactFeedbackGenerator(style: impacts[n]).impactOccurred(intensity: 1)
                rollingImpact(n: n + 1)
            }
        }
    }
}

extension Color {
    static let clear = Color.white.opacity(0.0001)
}

extension Font {
    static let miniIcon = Font.system(size: 20)
    static let icon = Font.system(size: 30)
    static let description = Font.system(size: 20, weight: .bold)
}

struct LeftAligned: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

struct RightAligned: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
        }
    }
}

struct CenterAligned: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

extension View {
    func alignLeft() -> some View {
        self.modifier(LeftAligned())
    }
    
    func alignRight() -> some View {
        self.modifier(RightAligned())
    }
    
    func alignCenter() -> some View {
        self.modifier(CenterAligned())
    }
}

