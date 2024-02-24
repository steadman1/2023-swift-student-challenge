//
//  File.swift
//  
//
//  Created by Spencer Steadman on 4/2/23.
//

import SwiftUI

struct AddGeometryButton: View {
    @ObservedObject var screen = Screen.shared
    @ObservedObject var arView = SharedARView.shared
    @Binding var isGeometryPresented: Bool
    
    var body: some View {
        ZStack {
            HStack {
                VStack {
                    Text("Add Geometry")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
                    Text("or create your own!")
                        .font(.body)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
                }
                Spacer()
                Button {
                    isGeometryPresented.toggle()
                } label: {
                    Image(systemName: "arkit")
                        .font(.icon)
                        .foregroundColor(.white)
                }.frame(width: 90 - Screen.doublePadding, height: 90 - Screen.doublePadding)
                    .background(.green)
                    .cornerRadius(Screen.cornerRadius - Screen.padding / 4)
            }.padding(.all, Screen.padding)
        }.frame(width: screen.width - Screen.padding * 2, height: 90)
            .background(.ultraThinMaterial)
            .cornerRadius(Screen.cornerRadius)
            .alignCenter()
    }
}
