import TransmissionKit
import TransmissionLocalization

// Keep the existing UI API; language packs have no dependency on SwiftUI or the daemon.
typealias AppLanguage = TransmissionLocalization.AppLanguage
typealias Localization = TransmissionLocalization.Localization

/// Reading the observable language from a view tracks runtime language changes.
@MainActor
func loc(_ key: String) -> String { Localization.shared.text(key) }

/// Torrent statuses use a separate vocabulary from settings labels.
@MainActor
func locStatus(_ source: String) -> String { Localization.shared.status(source) }

/// Localized text for an error. `RPCError`'s own descriptions are Hungarian (the Kit has no
/// access to `loc`), so its cases are translated here; the daemon's / system's detail text
/// is appended as-is.
@MainActor
func locError(_ error: Error) -> String {
    guard let rpc = error as? RPCError else { return error.localizedDescription }
    switch rpc {
    case .invalidURL: return loc("Érvénytelen szerver URL.")
    case .transport(let message): return loc("Hálózati hiba:") + " " + message
    case .http(let code): return loc("HTTP hiba:") + " \(code)"
    case .unauthorized: return loc("Hibás felhasználónév vagy jelszó.")
    case .rpcFailure(let message): return loc("A daemon hibát adott:") + " " + message
    case .decoding(let message): return loc("Feldolgozási hiba:") + " " + message
    case .missingSessionID: return loc("Nem sikerült megszerezni a session azonosítót.")
    }
}
