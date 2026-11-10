import Foundation

/// Un canal de TV ya convertido desde la lista M3U.
struct Canal: Identifiable, Hashable {
    let id = UUID()
    let nombre: String
    let grupo: String?
    let logo: URL?
    let url: URL
}
