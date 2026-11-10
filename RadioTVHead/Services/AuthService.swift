import Foundation

enum AuthError: LocalizedError {
    case camposVacios
    case credencialesInvalidas

    var errorDescription: String? {
        switch self {
        case .camposVacios:
            return "Completa todos los campos"
        case .credencialesInvalidas:
            return "Correo o contraseña incorrectos"
        }
    }
}

protocol AuthServiceProtocol {
    //func login(correo: String, password: String) async throws -> Usuario
    func login(correo: String, password: String) async throws -> Sesion

}

/// Servicio de demostración. Reemplaza el cuerpo de `login`
/// por una llamada real a tu API cuando la tengas.
struct AuthService: AuthServiceProtocol {
    func login(correo: String, password: String) async throws -> Sesion {
        // ... tus validaciones actuales igual ...

        // Con tu API real, el token viene en la respuesta del servidor
        return Sesion(
            usuario: Usuario(id: 1, correo: correo),
            token: UUID().uuidString
        )
    }
/*
    func login(correo: String, password: String) async throws -> Usuario {
        guard !correo.isEmpty, !password.isEmpty else {
            throw AuthError.camposVacios
        }

        // Simula el tiempo de respuesta de la red
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Credenciales de prueba
        guard correo == "admin@correo.com", password == "1234" else {
            throw AuthError.credencialesInvalidas
        }

        return Usuario(id: 1, correo: correo)
    }*/
}
