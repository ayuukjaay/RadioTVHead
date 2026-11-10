import Foundation
import Combine
import AVFoundation

@MainActor
final class ReproductorTVViewModel: ObservableObject {
    @Published private(set) var estado: EstadoReproduccion = .detenido
    @Published private(set) var player: AVPlayer?

    let canal: Canal

    @ObservationIgnored private var tareaTiempoLimite: Task<Void, Never>?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    init(canal: Canal) {
        self.canal = canal
    }

    func reproducir() {
        detener()
        configurarAudio()

        let item = AVPlayerItem(url: canal.url)
        let nuevoPlayer = AVPlayer(playerItem: item)
        player = nuevoPlayer
        estado = .cargando

        // Canal caído, restringido, formato no soportado o URL http bloqueada
        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .failed {
                    self?.marcarNoDisponible()
                }
            }
            .store(in: &cancellables)

        nuevoPlayer.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.actualizar(con: status)
            }
            .store(in: &cancellables)

        // Algunos servidores no fallan: se quedan cargando para siempre
        // (15 segundos y se da por no disponible)
        let segundosLimite: UInt64 = 15
        tareaTiempoLimite = Task { [weak self] in
            try? await Task.sleep(nanoseconds: segundosLimite * 1_000_000_000)
            guard !Task.isCancelled else { return }
            if self?.estado == .cargando {
                self?.marcarNoDisponible()
            }
        }

        nuevoPlayer.play()
    }

    func detener() {
        tareaTiempoLimite?.cancel()
        tareaTiempoLimite = nil
        cancellables.removeAll()
        player?.pause()
        player = nil
        estado = .detenido
    }

    private func marcarNoDisponible() {
        tareaTiempoLimite?.cancel()
        cancellables.removeAll()
        player?.pause()
        player = nil
        estado = .error("Contenido no disponible")
    }

    private func actualizar(con status: AVPlayer.TimeControlStatus) {
        if case .error = estado { return }

        switch status {
        case .playing:
            tareaTiempoLimite?.cancel()
            estado = .reproduciendo
        case .waitingToPlayAtSpecifiedRate:
            // Si ya estaba sonando y se corta un momento, no reiniciamos el contador
            if estado != .reproduciendo {
                estado = .cargando
            }
        case .paused:
            break
        @unknown default:
            break
        }
    }

    private func configurarAudio() {
        do {
            let sesion = AVAudioSession.sharedInstance()
            try sesion.setCategory(.playback, mode: .moviePlayback)
            try sesion.setActive(true)
        } catch {
            print("No se pudo configurar el audio:", error)
        }
    }
}
