import Foundation

/// Convierte el texto de una lista M3U en [Canal].
///
/// Formato esperado (cada canal ocupa dos líneas):
///   #EXTINF:-1 group-title="Noticias",Nombre del canal
///   https://servidor.com/stream.m3u8
enum M3UParser {

    static func parsear(_ texto: String) -> [Canal] {
        var canales: [Canal] = []
        var info: String?   // última línea #EXTINF pendiente de su URL

        for crudo in texto.components(separatedBy: .newlines) {
            let linea = crudo.trimmingCharacters(in: .whitespaces)
            if linea.isEmpty { continue }

            if linea.hasPrefix("#EXTINF") {
                info = linea

            } else if linea.hasPrefix(","), let actual = info {
                // Por si el nombre viene en la línea siguiente (",Nombre")
                info = actual + linea

            } else if linea.hasPrefix("#") {
                // #EXTM3U, #EXTVLCOPT y otras directivas: se ignoran
                continue

            } else if let actual = info,
                      let url = URL(string: linea),
                      let esquema = url.scheme?.lowercased(),
                      esquema == "http" || esquema == "https" {

                canales.append(
                    Canal(
                        nombre: nombre(de: actual),
                        grupo: atributo("group-title", en: actual),
                        logo: atributo("tvg-logo", en: actual).flatMap { URL(string: $0) },
                        url: url
                    )
                )
                info = nil
            }
        }

        return canales
    }

    /// El nombre es lo que viene después de la ÚLTIMA coma.
    private static func nombre(de info: String) -> String {
        guard let coma = info.lastIndex(of: ",") else {
            return "Canal sin nombre"
        }
        let texto = info[info.index(after: coma)...]
            .trimmingCharacters(in: .whitespaces)
        return texto.isEmpty ? "Canal sin nombre" : texto
    }

    /// Lee atributos tipo clave="valor" dentro de la línea #EXTINF.
    private static func atributo(_ clave: String, en info: String) -> String? {
        guard let rango = info.range(of: "\(clave)=\"") else { return nil }
        let resto = info[rango.upperBound...]
        guard let fin = resto.firstIndex(of: "\"") else { return nil }
        let valor = String(resto[..<fin])
        return valor.isEmpty ? nil : valor
    }
}
