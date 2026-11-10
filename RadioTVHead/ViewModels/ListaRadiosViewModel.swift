import Foundation

@MainActor
@Observable
final class ListaRadiosViewModel {
    private(set) var estaciones: [Estacion] = []
    private(set) var cargando = false
    private(set) var mensajeError: String?

    private let service: RadioServiceProtocol
    @ObservationIgnored private var yaCargo = false

    init(service: RadioServiceProtocol = RadioService()) {
        self.service = service
    }

    /// Se llama desde la vista al aparecer. Solo descarga la PRIMERA vez,
    /// así volver desde el reproductor no gasta otra petición.
    func cargarSiHaceFalta() async {
        guard !yaCargo, !cargando else { return }
        await cargar()
    }

    /// Descarga manual (pull to refresh o botón Reintentar). Cuenta como petición.
    func recargar() async {
        guard !cargando else { return }
        await cargar()
    }

    private func cargar() async {
        cargando = true
        mensajeError = nil
        defer { cargando = false }

        do {
            let lista = try await service.estacionesAleatorias(limite: 10)
            // Solo mostramos estaciones que sí tienen un stream que podemos reproducir
            estaciones = lista.filter { $0.urlReproducible != nil }
            yaCargo = true
        } catch is CancellationError {
            // La vista desapareció a media descarga: no es un error real
        } catch let error as URLError where error.code == .cancelled {
            // Igual: petición cancelada
        } catch {
            mensajeError = error.localizedDescription
        }
    }
}
