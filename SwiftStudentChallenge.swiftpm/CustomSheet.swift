//
//  CustomSheet.swift
//  Challenge
//
//  Created by Spencer Steadman on 4/3/23.
//

import SwiftUI

struct CustomSheet<Content: View, LabelContent: View>: View {
    @ObservedObject var screen = Screen.shared
    @Binding var isPresented: Bool
    @State var animation: Double = 0
    @State var dragHeight: Double = 0
    @State var dragHeightStart: Double = 0
    let size = 250.0
    let content: Content
    let label: LabelContent
    
    let dismissRadius = 100.0
    
    init(isPresented: Binding<Bool>,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder label: @escaping () -> LabelContent) {
        
        self._isPresented = isPresented
        if isPresented.wrappedValue {
            self._animation = State(initialValue: 1)
        }
        self.content = content()
        self.label = label()
    }
    
    var body: some View {
        var position = screen.height + screen.halfHeight + screen.safeAreaInsets.bottom - (size * animation)
        if dragHeight > 0 {
            position = screen.halfHeight + dragHeight - 57
        } else if NavigationBar.shared.isShowing {
            position -= NavigationBar.height
        }
        
        return ZStack {
            content
            
            ZStack {
                VStack {
                    Spacer().frame(height: 30)
                    label.frame(width: screen.width,
                                height: size + (dragHeightStart - dragHeight) - screen.safeAreaInsets.bottom - 30)
                    Spacer()
                }.frame(width: screen.width, height: screen.height + screen.safeAreaInsets.top + screen.safeAreaInsets.bottom)
                    .background(.white)
                    .cornerRadius(Screen.cornerRadius)
                
                VStack {
                    Spacer().frame(height: 12)
                    Rectangle()
                        .frame(width: 50, height: 6)
                        .foregroundColor(.gray.opacity(0.25))
                        .cornerRadius(100)
                    Spacer().frame(height: 12)
                }.frame(width: screen.width)
                    .background(Color.white)
                    .cornerRadius(100)
                    .offset(x: 0, y: -screen.halfHeight + 15)
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { drag in
                                if drag.location.y < screen.safeAreaInsets.top {
                                    return
                                } else if drag.location.y > 0 {
                                    dragHeight = drag.location.y
                                    dragHeightStart = drag.startLocation.y
                                } else {
                                    dragHeightStart = 0
                                    withAnimation(.sheetBounce) {
                                        dragHeight = 0
                                    }
                                }
                            }.onEnded { drag in
                                if drag.location.y > screen.height - dismissRadius {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        dragHeight = 0
                                        dragHeightStart = 0
                                        animation = 0
                                        isPresented = false
                                    }
                                } else {
                                    withAnimation(.sheetBounce) {
                                        dragHeight = 0
                                        dragHeightStart = 0
                                    }
                                }
                            }
                    )
            }.position(x: screen.halfWidth, y: position)
        }.frame(width: screen.width)
            .onChange(of: isPresented) { newValue in
                if newValue {
                    withAnimation(.sheetBounce) {
                        animation = 1
                    }
                } else {
                    withAnimation(.easeIn(duration: 0.25)) {
                        animation = 0
                    }
                }
            }
    }
}

struct CustomSheetModifier<LabelContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let label: LabelContent

    func body(content: Content) -> some View {
        CustomSheet(isPresented: $isPresented) {
            content
        } label: {
            label
        }
    }
}

extension View {
    func customSheet<LabelContent>(isPresented: Binding<Bool>,
                              @ViewBuilder label: @escaping () -> LabelContent) -> some View where LabelContent: View {
        
        self.modifier(CustomSheetModifier(isPresented: isPresented, label: label()))
    }
}

extension Animation {
    static let sheetBounce: Animation = .interpolatingSpring(stiffness: 250, damping: 20)
}
