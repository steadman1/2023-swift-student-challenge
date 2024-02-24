import SwiftUI

struct ContentView: View {
    @ObservedObject var screen = Screen.shared
    @ObservedObject var arview = SharedARView.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ARMain()
                    .frame(alignment: .center)
                Overlay()
            }.onAppear {
                screen.width = geometry.size.width
                screen.height = geometry.size.height
            }.onChange(of: geometry.size) { newValue in
                screen.width = newValue.width
                screen.height = newValue.height
            }
        }.sheet(isPresented: Binding.constant(arview.arState == .tutorial)) {
            Introduction()
        }
    }
}
