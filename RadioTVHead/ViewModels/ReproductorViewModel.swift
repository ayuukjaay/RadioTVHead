import Foundation
import Combine
import AVFoundation

@MainActor
final class ReproductorViewModel: ObservableObject {
    @Published private(set) var estado: EstadoReproduccion = .detenido

    let estacion: Estacion

    private var player: AVPlayer?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    init(estacion: Estacion) {
        self.estacion = estacion
    }

    /// true mientras está cargando o sonando (el botón muestra "pausa")
    var estaActivo: Bool {
        estado == .reproduciendo || estado == .cargando
    }

    func reproducir() {
        guard let url = estacion.urlReproducible else {
            estado = .error("Esta estación no tiene una transmisión compatible")
            return
        }

        detener()
        configurarAudio()

        let item = AVPlayerItem(url: url)
        let nuevoPlayer = AVPlayer(playerItem: item)
        player = nuevoPlayer
        estado = .cargando

        // Si el stream falla (URL caída, formato no soportado, etc.)
        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .failed {
                    self?.estado = .error("No se pudo reproducir esta estación")
                }
            }
            .store(in: &cancellables)

        // Para saber si está sonando o almacenando buffer
        nuevoPlayer.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.actualizar(con: status)
            }
            .store(in: &cancellables)

        nuevoPlayer.play()
    }

    /// En radio en vivo no tiene sentido "pausar": se detiene y,
    /// al volver a pulsar play, se reconecta a lo que suena ahora.
    func detener() {
        cancellables.removeAll()
        player?.pause()
        player = nil
        estado = .detenido
    }

    func alternar() {
        if estaActivo {
            detener()
        } else {
            reproducir()
        }
    }

    private func actualizar(con status: AVPlayer.TimeControlStatus) {
        if case .error = estado { return }

        switch status {
        case .playing:
            estado = .reproduciendo
        case .waitingToPlayAtSpecifiedRate:
            estado = .cargando
        case .paused:
            break
        @unknown default:
            break
        }
    }

    private func configurarAudio() {
        do {
            let sesion = AVAudioSession.sharedInstance()
            try sesion.setCategory(.playback, mode: .default)
            try sesion.setActive(true)
        } catch {
            print("No se pudo configurar el audio:", error)
        }
    }
}
