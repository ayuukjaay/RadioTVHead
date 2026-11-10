import SwiftUI

struct ReproductorView: View {
    @State private var viewModel: ReproductorViewModel

    init(estacion: Estacion) {
        _viewModel = State(initialValue: ReproductorViewModel(estacion: estacion))
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "radio")
                .font(.system(size: 90))
                .foregroundStyle(.tint)

            VStack(spacing: 6) {
                Text(viewModel.estacion.name)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text("\(viewModel.estacion.genero) · \(viewModel.estacion.pais)")
                    .foregroundStyle(.secondary)
            }

            textoEstado
                .frame(height: 24)

            Button {
                viewModel.alternar()
            } label: {
                Image(systemName: viewModel.estaActivo ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 76))
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Reproduciendo")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.reproducir() }
        .onDisappear { viewModel.detener() }
    }

    @ViewBuilder
    private var textoEstado: some View {
        switch viewModel.estado {
        case .detenido:
            Text("Detenido")
                .foregroundStyle(.secondary)
        case .cargando:
            HStack(spacing: 8) {
                ProgressView()
                Text("Conectando…")
            }
            .foregroundStyle(.secondary)
        case .reproduciendo:
            Label("En vivo", systemImage: "dot.radiowaves.left.and.right")
                .foregroundStyle(.green)
        case .error(let mensaje):
            Text(mensaje)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
    }
}
