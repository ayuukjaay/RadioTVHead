import SwiftUI

/// Vista raíz: decide qué pantalla mostrar según el enum.
struct RootView: View {
    @Environment(SesionViewModel.self) private var sesion

    var body: some View {
        Group {
            switch sesion.pantalla {
            case .login:
                LoginView()
            case .menu:
                MenuView()
            }
        }
        .animation(.easeInOut, value: sesion.pantalla)
    }
}
