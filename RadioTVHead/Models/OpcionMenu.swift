import Foundation

/// Opciones que aparecen en el menú principal.
enum OpcionMenu: String, CaseIterable, Identifiable {
    case radio = "Lista de estaciones de Radio"
    case tv = "Lista de Canales de TV"

    var id: String { rawValue }

    var icono: String {
        switch self {
        case .radio: return "radio.fill"
        case .tv: return "tv.fill"
        }
    }
}
