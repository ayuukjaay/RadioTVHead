import Foundation
import Observation

@MainActor
@Observable
final class ListaCanalesViewModel {
    private(set)  var canales: [Canal] = []
    private(set)  var cargando = false
    private(set)  var mensajeError: String?

    private let service: TVServiceProtocol
    @ObservationIgnored private var yaCargo = false

    init(service: TVServiceProtocol = TVService()) {
        self.service = service
    }

    /// Solo descarga la primera vez que aparece la pantalla.
    func cargarSiHaceFalta() async {
        guard !yaCargo, !cargando else { return }
        await cargar()
    }

    /// Descarga manual (pull to refresh o botón Reintentar).
    func recargar() async {
        guard !cargando else { return }
        await cargar()
    }

    private func cargar() async {
        cargando = true
        mensajeError = nil
        defer { cargando = false }

        do {
            canales = try await service.canales()
            yaCargo = true
        } catch is CancellationError {
            // La vista desapareció a media descarga: no es un error real
        } catch let error as URLError where error.code == .cancelled {
            // Petición cancelada
        } catch {
            mensajeError = error.localizedDescription
        }
    }
}
