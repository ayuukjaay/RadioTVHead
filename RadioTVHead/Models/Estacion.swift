import Foundation

/// Respuesta de GET /radios/random: la lista viene dentro de `data`.
struct RespuestaEstaciones: Decodable {
    let data: [Estacion]
}

struct Genero: Decodable {
    let text: String?
}

struct Ubicacion: Decodable {
    let countryName: String?
}

/// Una de las URLs de audio de la estación (campo `streams`).
struct StreamRadio: Decodable {
    let url: String
    let isHttps: Bool?
    let codec: String?
    let bitrate: Int?
    let works: Bool?

    enum CodingKeys: String, CodingKey {
        case url, isHttps, codec, bitrate, works
    }

    // Decodificación tolerante: si un campo opcional viene raro,
    // no se rompe toda la lista.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        url = try c.decode(String.self, forKey: .url)
        isHttps = try? c.decodeIfPresent(Bool.self, forKey: .isHttps)
        codec = try? c.decodeIfPresent(String.self, forKey: .codec)
        works = try? c.decodeIfPresent(Bool.self, forKey: .works)

        if let n = try? c.decodeIfPresent(Int.self, forKey: .bitrate) {
            bitrate = n
        } else if let d = try? c.decodeIfPresent(Double.self, forKey: .bitrate) {
            bitrate = Int(d)
        } else if let s = try? c.decodeIfPresent(String.self, forKey: .bitrate),
                  let n = Int(s) {
            bitrate = n
        } else {
            bitrate = nil
        }
    }

    var usaHttps: Bool {
        isHttps == true || url.lowercased().hasPrefix("https://")
    }

    // StreamRadio
    var esReproducible: Bool {
        guard works != false else { return false }
        return !(codec?.lowercased().contains("ogg") ?? false)   // AVPlayer no soporta Ogg
    }
}

struct Estacion: Decodable, Identifiable, Hashable {
    let id = UUID()
    let name: String
    let genre: Genero?
    let location: Ubicacion?
    let streams: [StreamRadio]?

    enum CodingKeys: String, CodingKey {
        case name, genre, location, streams
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = (try? c.decode(String.self, forKey: .name)) ?? "Sin nombre"
        genre = try? c.decodeIfPresent(Genero.self, forKey: .genre)
        location = try? c.decodeIfPresent(Ubicacion.self, forKey: .location)
        streams = try? c.decodeIfPresent([StreamRadio].self, forKey: .streams)
    }

    // Hashable solo por id (necesario para NavigationLink(value:))
    static func == (lhs: Estacion, rhs: Estacion) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    // MARK: - Datos para mostrar

    var genero: String { genre?.text ?? "Sin género" }
    var pais: String { location?.countryName ?? "País desconocido" }

    // MARK: - Selección del stream

    // Estacion
    var urlReproducible: URL? {
        let elegido = (streams ?? [])
            .filter { $0.esReproducible }
            .sorted {
                // Prefiere HTTPS; entre iguales, el de mayor bitrate
                if $0.usaHttps != $1.usaHttps { return $0.usaHttps }
                return ($0.bitrate ?? 0) > ($1.bitrate ?? 0)
            }
            .first
        return elegido.flatMap { URL(string: $0.url) }
    }
}
