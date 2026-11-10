import SwiftUI

@main
struct MyApp: App {
    @State private var sesion = SesionViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sesion)
        }
    }
}
