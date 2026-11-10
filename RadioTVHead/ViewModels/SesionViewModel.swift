import Foundation

@MainActor
@Observable
final class SesionViewModel {
    private(set) var pantalla: PantallaApp = .login
    private(set) var usuario: Usuario?

    private let keychain = KeychainService()

    init() {
        // Al abrir la app: ¿hay una sesión guardada?
        if let datos = keychain.leer(),
           let sesion = try? JSONDecoder().decode(Sesion.self, from: datos) {
            usuario = sesion.usuario
            pantalla = .menu
        }
    }

    func iniciarSesion(_ sesion: Sesion) {
        if let datos = try? JSONEncoder().encode(sesion) {
            try? keychain.guardar(datos)
        }
        usuario = sesion.usuario
        pantalla = .menu
    }

    func cerrarSesion() {
        keychain.borrar()
        usuario = nil
        pantalla = .login
    }
}
