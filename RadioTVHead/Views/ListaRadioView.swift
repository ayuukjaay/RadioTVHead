import SwiftUI

struct ListaRadiosView: View {
    @State private var viewModel = ListaRadiosViewModel()

    var body: some View {
        Group {
            if viewModel.cargando && viewModel.estaciones.isEmpty {
                ProgressView("Cargando estaciones…")
            } else if let error = viewModel.mensajeError, viewModel.estaciones.isEmpty {
                vistaError(error)
            } else {
                lista
            }
        }
        .navigationTitle("Radio")
        .navigationBarTitleDisplayMode(.inline)
        // .task se ejecuta al aparecer, pero el ViewModel ignora
        // las llamadas repetidas: solo descarga una vez.
        .task {
            await viewModel.cargarSiHaceFalta()
        }
    }

    private var lista: some View {
        List(viewModel.estaciones) { estacion in
            NavigationLink(value: estacion) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(estacion.name)
                        .font(.headline)
                    Text("\(estacion.genero) · \(estacion.pais)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
        .navigationDestination(for: Estacion.self) { estacion in
            ReproductorView(estacion: estacion)
        }
        // Arrastrar hacia abajo pide otras estaciones aleatorias (gasta 1 petición)
        .refreshable {
            await viewModel.recargar()
        }
    }

    private func vistaError(_ mensaje: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(mensaje)
                .multilineTextAlignment(.center)
            Button("Reintentar") {
                Task { await viewModel.recargar() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        ListaRadiosView()
    }
}
