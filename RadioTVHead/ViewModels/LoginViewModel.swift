import Foundation

@MainActor
@Observable
final class LoginViewModel {
    var correo = ""
    var password = ""
    private(set) var mensajeError: String?
    private(set) var cargando = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    /// Devuelve el usuario si el login fue exitoso, o nil si falló.
    func iniciarSesion() async -> Sesion? {
        mensajeError = nil
        cargando = true
        defer { cargando = false }

        do {
            let sesion = try await authService.login(correo: correo, password: password)
            password = ""   // la contraseña no se queda en memoria
            return sesion
        } catch {
            mensajeError = error.localizedDescription
            return nil
        }
    }
    /*
    
    func iniciarSesion() async -> Usuario? {
        mensajeError = nil
        cargando = true
        defer { cargando = false }

        do {
            return try await authService.login(correo: correo, password: password)
        } catch {
            mensajeError = error.localizedDescription
            return nil
        }
    }*/
}
