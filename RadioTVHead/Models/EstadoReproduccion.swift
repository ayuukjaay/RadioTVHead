import Foundation

enum EstadoReproduccion: Equatable {
    case detenido
    case cargando
    case reproduciendo
    case error(String)
}
