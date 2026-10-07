import Foundation

/// Everything a language needs, kept separate from UI and RPC code.
/// Statuses have their own table: "Letöltés" means "Download" in settings,
/// but "Downloading" in the torrent list.
public struct LanguagePack: Sendable {
    public let title: String
    public let localeIdentifier: String
    public let languageCodes: [String]
    public let strings: [String: String]
    public let statuses: [String: String]

    public init(title: String, localeIdentifier: String, languageCodes: [String],
                strings: [String: String] = [:], statuses: [String: String] = [:]) {
        self.title = title
        self.localeIdentifier = localeIdentifier
        self.languageCodes = languageCodes
        self.strings = strings
        self.statuses = statuses
    }

    public func text(_ key: String, fallback: LanguagePack) -> String {
        strings[key] ?? fallback.strings[key] ?? key
    }

    func matches(_ identifier: String) -> Bool {
        let language = Locale.Language(identifier: identifier.replacingOccurrences(of: "_", with: "-"))
        return languageCodes.contains { code in
            let supported = Locale.Language(identifier: code)
            return language.languageCode == supported.languageCode
                && language.script == supported.script
        }
    }
}
