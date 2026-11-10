import SwiftUI

struct MenuView: View {
    //@Environment var sesion: SesionViewModel
    @Environment(SesionViewModel.self) private var sesion

    var body: some View {
        
        NavigationStack {
            let usuario = sesion.usuario
            List {
                Section("Menú") {
                    ForEach(OpcionMenu.allCases) { opcion in
                        NavigationLink(value: opcion) {
                            Label(opcion.rawValue, systemImage: opcion.icono)
                        }
                    }
                }
                
                Section{
                    Button("Cerrar sesión") {
                            sesion.cerrarSesion()
                        }
                }
            }
            .navigationTitle("Hola, \(usuario?.nombreCorto ?? "Invitado")")
            .navigationDestination(for: OpcionMenu.self) { opcion in
                switch opcion {
                case .radio:
                    ListaRadiosView()
                case .tv:
                    ListaCanalesView()
                }
            }
        }
    }
}
