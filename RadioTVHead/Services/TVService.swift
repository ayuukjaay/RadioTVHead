import Foundation

enum TVError: LocalizedError {
    case urlInvalida
    case servidor(Int)
    case contenidoInvalido
    case listaVacia

    var errorDescription: String? {
        switch self {
        case .urlInvalida:
            return "La URL de la lista de canales no es válida"
        case .servidor(let codigo):
            return "No se pudo descargar la lista (código \(codigo))"
        case .contenidoInvalido:
            return "No se pudo leer el contenido de la lista"
        case .listaVacia:
            return "La lista no contiene canales"
        }
    }
}

protocol TVServiceProtocol {
    func canales() async throws -> [Canal]
}

struct TVService: TVServiceProtocol {
    static let urlLista = "https://iptv-org.github.io/iptv/countries/mx.m3u"

    func canales() async throws -> [Canal] {
        guard let url = URL(string: Self.urlLista) else {
            throw TVError.urlInvalida
        }

        let (datos, respuesta) = try await URLSession.shared.data(from: url)

        guard let http = respuesta as? HTTPURLResponse else {
            throw TVError.contenidoInvalido
        }
        guard (200...299).contains(http.statusCode) else {
            throw TVError.servidor(http.statusCode)
        }

        guard let texto = String(data: datos, encoding: .utf8)
                ?? String(data: datos, encoding: .isoLatin1) else {
            throw TVError.contenidoInvalido
        }

        let lista = M3UParser.parsear(texto)
        guard !lista.isEmpty else {
            throw TVError.listaVacia
        }
        return lista
    }
}
