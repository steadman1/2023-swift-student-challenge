import SwiftUI

@main
struct MyApp: App {
    @ObservedObject var screen = Screen.shared
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                ZStack {
                    ContentView()
                        .preferredColorScheme(.light)
                }.onAppear {
                    screen.width = geometry.size.width
                    screen.height = geometry.size.height
                    screen.safeAreaInsets = geometry.safeAreaInsets
                }.onChange(of: geometry.size) { newValue in
                    SharedARView.shared.arView.frame = CGRect(x: 0,
                                                              y: 0,
                                                              width: screen.width,
                                                              height: screen.height)
                    screen.width = newValue.width
                    screen.height = newValue.height
                    screen.safeAreaInsets = geometry.safeAreaInsets
                }
            }
        }
    }
}
