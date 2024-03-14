//
//  File.swift
//  
//
//  Created by Spencer Steadman on 4/4/23.
//

import SwiftUI

struct GeometryListItem {
    let icon: Image
    let name: String
    let addGeometry: () -> Void
}


struct AddGeometryCarousel: View {
    @ObservedObject var arView = SharedARView.shared
    @Binding var isPresented: Bool
    @Binding var selection: Int
    let title: String
    let subtitle: String
    
    let geometryList: [GeometryListItem] = [
        GeometryListItem(icon: Image("cube"),
                         name: "Cube",
                         addGeometry: SharedARView.shared.placeBox),
        GeometryListItem(icon: Image("sphere"),
                         name: "Sphere",
                         addGeometry: SharedARView.shared.placeBox),
        GeometryListItem(icon: Image("cone"),
                         name: "Cone",
                         addGeometry: SharedARView.shared.placeBox),
//        GeometryListItem(icon: Image(systemName: "plus.square.dashed"),
//                         name: "Create Object",
//                         addGeometry: SharedARView.shared.placeBox),
    ]

    private let scaleFactors = [1.0, 0.5, 0.0]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Text(title)
                        .font(.title2.bold())
                        .alignLeft()
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(.gray)
                        .alignLeft()
                    Spacer()
                    HStack(spacing: 0) {
                        ForEach(Array(zip(geometryList.indices, geometryList)), id: \.0) { index, item in
                            VStack {
                                item.icon
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 130, height: 130)
                                    .shadow(color: .gray.opacity(0.6), radius: 12, y: 15)
                                Spacer().frame(height: Screen.doublePadding)
                                Text(item.name)
                                    .font(.title2.bold())
                            }.frame(width: geometry.size.width / 3, height: 200)
                                .background(.clear)
                                .tag(index)
                                .scaleEffect(scaleFactor(index))
                                .opacity(opacity(index))
                                .onTapGesture {
                                    arView.generateBox(SIMD3<Float>(0, 0, 0))
                                }
                        }
                    }.frame(width: geometry.size.width, alignment: .leading)
                        .offset(x: offset(geometry: geometry))
                    Spacer()
                }.frame(width: geometry.size.width, height: geometry.size.height)
                    .background(.clear)
                    .padding([.leading, .trailing], Screen.padding)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 0 {
                                    withAnimation(.carousel) {
                                        if selection > 0 {
                                            selection -= 1
                                        } else {
                                            selection = geometryList.count - 1
                                        }
                                    }
                                } else {
                                    withAnimation(.carousel) {
                                        if selection < geometryList.count - 1 {
                                            selection += 1
                                        } else {
                                            selection = 0
                                        }
                                    }
                                }
                            }
                    )
                
                HStack {
                    Button {
                        withAnimation(.carousel) {
                            if selection > 0 {
                                selection -= 1
                            } else {
                                selection = geometryList.count - 1
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.miniIcon.bold())
                    }.padding(Screen.padding)
                        .background(.gray.opacity(0.25))
                        .foregroundColor(.green)
                        .cornerRadius(100)
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(0..<Int(geometryList.count), id: \.self) { index in
                            Circle()
                                .foregroundColor(selection == index ? .green : .gray.opacity(0.25))
                                .frame(width: 7, height: 7)
                        }
                    }
                    
                    Spacer()
                    Button {
                        withAnimation(.carousel) {
                            if selection < geometryList.count - 1 {
                                selection += 1
                            } else {
                                selection = 0
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.miniIcon.bold())
                    }.padding(Screen.padding)
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(100)
                        
                }.frame(width: geometry.size.width - Screen.doublePadding, height: 35)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 17.5)
            }
        }
    }

    private func scaleFactor(_ index: Int) -> CGFloat {
        let abs = abs(selection - index)
        let scaleIndex = abs > 1 ? 2 : abs
        return CGFloat(scaleFactors[scaleIndex])
    }

    private func opacity(_ index: Int) -> Double {
        return index == selection ? 1.0 : 0.5
    }

    private func offset(geometry: GeometryProxy) -> CGFloat {
        let center = geometry.size.width / 2 - Screen.padding
        let tabWidth = geometry.size.width / 3
        return center - tabWidth / 2 - CGFloat(selection) * tabWidth
    }
}

extension Animation {
    static let carousel = Animation.easeInOut(duration: 0.2)
}
