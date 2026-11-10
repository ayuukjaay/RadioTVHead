import Foundation
import Security

enum KeychainError: Error {
    case estado(OSStatus)
}

struct KeychainService {
    private let servicio = Bundle.main.bundleIdentifier ?? "MyApp"
    private let cuenta = "sesion"

    private var consultaBase: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: cuenta
        ]
    }

    func guardar(_ datos: Data) throws {
        borrar() // reemplaza lo anterior

        var consulta = consultaBase
        consulta[kSecValueData as String] = datos
        consulta[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let estado = SecItemAdd(consulta as CFDictionary, nil)
        guard estado == errSecSuccess else {
            throw KeychainError.estado(estado)
        }
    }

    func leer() -> Data? {
        var consulta = consultaBase
        consulta[kSecReturnData as String] = true
        consulta[kSecMatchLimit as String] = kSecMatchLimitOne

        var resultado: AnyObject?
        let estado = SecItemCopyMatching(consulta as CFDictionary, &resultado)
        guard estado == errSecSuccess else { return nil }
        return resultado as? Data
    }

    func borrar() {
        SecItemDelete(consultaBase as CFDictionary)
    }
}
