import SwiftUI

struct ListaCanalesView: View {
    @State private var viewModel = ListaCanalesViewModel()

    var body: some View {
        Group {
            if viewModel.cargando && viewModel.canales.isEmpty {
                ProgressView("Cargando canales…")
            } else if let error = viewModel.mensajeError, viewModel.canales.isEmpty {
                vistaError(error)
            } else {
                lista
            }
        }
        .navigationTitle("TV")
        .navigationBarTitleDisplayMode(.inline)
        // El ViewModel ignora las llamadas repetidas: solo descarga una vez.
        .task {
            await viewModel.cargarSiHaceFalta()
        }
    }

    private var lista: some View {
        List(viewModel.canales) { canal in
            NavigationLink(value: canal) {
                HStack(spacing: 12) {
                    logo(de: canal)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(canal.nombre)
                            .font(.headline)
                        if let grupo = canal.grupo {
                            Text(grupo)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationDestination(for: Canal.self) { canal in
            ReproductorTVView(canal: canal)
        }
        .refreshable {
            await viewModel.recargar()
        }
    }

    private func logo(de canal: Canal) -> some View {
        AsyncImage(url: canal.logo) { imagen in
            imagen
                .resizable()
                .scaledToFit()
        } placeholder: {
            Image(systemName: "tv")
                .foregroundStyle(.secondary)
        }
        .frame(width: 44, height: 44)
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
        ListaCanalesView()
    }
}
