import SwiftUI
import AVKit

struct ReproductorTVView: View {
    @State private var viewModel: ReproductorTVViewModel

    init(canal: Canal) {
        _viewModel = State(initialValue: ReproductorTVViewModel(canal: canal))
    }

    var body: some View {
        VStack(spacing: 16) {
            pantalla
                .aspectRatio(16 / 9, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .background(Color.black)

            VStack(spacing: 6) {
                Text(viewModel.canal.nombre)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                if let grupo = viewModel.canal.grupo {
                    Text(grupo)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("TV")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.reproducir() }
        .onDisappear { viewModel.detener() }
    }

    @ViewBuilder
    private var pantalla: some View {
        ZStack {
            if let player = viewModel.player {
                VideoPlayer(player: player)
            }

            switch viewModel.estado {
            case .cargando:
                VStack(spacing: 8) {
                    ProgressView()
                        .tint(.white)
                    Text("Conectando…")
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
            case .error(let mensaje):
                avisoNoDisponible(mensaje)
            case .detenido, .reproduciendo:
                EmptyView()
            }
        }
    }

    private func avisoNoDisponible(_ mensaje: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.yellow)
            Text(mensaje)
                .font(.headline)
                .foregroundStyle(.white)
            Text("Este canal puede estar caído o restringido en tu región.")
                .font(.footnote)
                .foregroundStyle(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
            Button("Reintentar") {
                viewModel.reproducir()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
