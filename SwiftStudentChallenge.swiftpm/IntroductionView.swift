//
//  File.swift
//  
//
//  Created by Spencer Steadman on 4/2/23.
//

import SwiftUI

struct IntroductionListItem {
    var icon: Image
    var name: String
}

struct Introduction: View {
    let items: [IntroductionListItem] = [
        IntroductionListItem(icon: Image(systemName: "arkit"),
                         name: "Scan a surface"),
        IntroductionListItem(icon: Image(systemName: "rectangle.and.hand.point.up.left.filled"),
                         name: "Place objects"),
        IntroductionListItem(icon: Image(systemName: "bubbles.and.sparkles.fill"),
                         name: "And have fun!"),
    ]
    var body: some View {
        VStack {
            Spacer().frame(height: Screen.padding * 2)
            Text("Welcome to\nSandbox! 👋")
                .font(.largeTitle.bold())
                .alignLeft()
            Spacer()
            VStack(spacing: Screen.padding) {
                ForEach(Array(zip(items.indices, items)), id: \.0) { (index, item) in
                    HStack {
                        item.icon
                            .font(.icon)
                        Spacer().frame(width: Screen.padding * 2)
                        Text(item.name)
                            .font(.description)
                    }
                }
            }
            Spacer()
            Button {
                print("explore my sandbox")
            } label: {
                ZStack {
                    Text("Explore my Sandbox!")
                        .font(.description)
                }.frame(width: Screen.widthToLargestIPhone, height: 70)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(Screen.cornerRadius)
            }
            Button {
                SharedARView.shared.arState = .detectFloor
            } label: {
                ZStack {
                    Text("Continue")
                        .font(.description)
                }.frame(width: Screen.widthToLargestIPhone, height: 70)
                    .background(Color.gray.opacity(0.25))
                    .foregroundColor(.blue)
                    .cornerRadius(Screen.cornerRadius)
            }

        }.padding(Screen.padding)
    }
}
