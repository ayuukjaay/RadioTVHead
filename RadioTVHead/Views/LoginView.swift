import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @Environment(SesionViewModel.self) private var sesion

    var body: some View {
        Form {
            Section("Credenciales") {
                TextField("Correo", text: $viewModel.correo)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textContentType(.username)

                SecureField("Contraseña", text: $viewModel.password)
                    .textContentType(.password)
            }

            if let error = viewModel.mensajeError {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task {
                        if let usuario = await viewModel.iniciarSesion() {
                            sesion.iniciarSesion(usuario)
                        }
                    }
                } label: {
                    if viewModel.cargando {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Entrar")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.cargando)
            }footer: {
                Text("Usuario: admin@correo.com · Contraseña: 1234")}
        }
    }
}

#Preview {
    LoginView()
        .environment(SesionViewModel())
}
