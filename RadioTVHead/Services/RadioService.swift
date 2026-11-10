import Foundation

enum RadioError: LocalizedError {
    case claveNoConfigurada
    case urlInvalida
    case respuestaInvalida
    case noAutorizado
    case limiteAlcanzado
    case servidor(Int)

    var errorDescription: String? {
        switch self {
        case .claveNoConfigurada:
            return "Falta tu clave de RapidAPI en ApiConfig.swift"
        case .urlInvalida:
            return "La URL de la API no es válida"
        case .respuestaInvalida:
            return "La respuesta del servidor no tiene el formato esperado"
        case .noAutorizado:
            return "Clave de RapidAPI inválida o sin suscripción a la API"
        case .limiteAlcanzado:
            return "Alcanzaste el límite de peticiones del plan gratuito. Intenta más tarde"
        case .servidor(let codigo):
            return "Error del servidor (código \(codigo))"
        }
    }
}

protocol RadioServiceProtocol {
    func estacionesAleatorias(limite: Int) async throws -> [Estacion]
}

struct RadioService: RadioServiceProtocol {
    func estacionesAleatorias(limite: Int) async throws -> [Estacion] {
        guard !ApiConfig.rapidAPIKey.isEmpty,
              ApiConfig.rapidAPIKey != ApiConfig.marcador else {
            throw RadioError.claveNoConfigurada
        }

        var componentes = URLComponents()
        componentes.scheme = "https"
        componentes.host = ApiConfig.host
        componentes.path = "/radios/random"
        componentes.queryItems = [URLQueryItem(name: "limit", value: String(limite))]

        guard let url = componentes.url else {
            throw RadioError.urlInvalida
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue(ApiConfig.host, forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(ApiConfig.rapidAPIKey, forHTTPHeaderField: "x-rapidapi-key")

        let (datos, respuesta) = try await URLSession.shared.data(for: request)

        guard let http = respuesta as? HTTPURLResponse else {
            throw RadioError.respuestaInvalida
        }

        switch http.statusCode {
        case 200...299:
            break
        case 401, 403:
            throw RadioError.noAutorizado
        case 429:
            throw RadioError.limiteAlcanzado
        default:
            throw RadioError.servidor(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(RespuestaEstaciones.self, from: datos).data
        } catch {
            throw RadioError.respuestaInvalida
        }
    }
}
