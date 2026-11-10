import Foundation

struct Usuario: Identifiable, Equatable, Codable {
    let id: Int
    let correo: String
    
    var nombreCorto: String {
            correo.components(separatedBy: "@").first ?? correo
        }
}

struct Sesion: Codable {
    let usuario: Usuario
    let token: String
}
