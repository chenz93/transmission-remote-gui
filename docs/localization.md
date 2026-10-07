# Language packs

Select **Settings → General → Language → 简体中文** for Simplified Chinese. The
choice is saved under the existing `appLanguage` preference and takes effect
immediately, including native table headers. **System** uses the first supported
macOS language preference, or English if none is supported. Simplified Chinese
matches `zh-Hans` / `zh-CN` / `zh-SG`; Traditional Chinese does not silently select
the Simplified Chinese pack.

## Structure

`Sources/TransmissionLocalization/` is a small Foundation/Observation-only module:

- `LanguagePack.swift`: native display name, formatting locale, matching language
  codes, UI strings and a separate torrent-status vocabulary.
- `English.swift`: the existing Hungarian → English dictionary.
- `SimplifiedChinese.swift`: independently written Simplified Chinese strings;
  familiar BitTorrent terminology follows the classic transgui UI where useful.
- `Localization.swift`: language registration, preference persistence, observable
  runtime switching and common fallback/formatting behavior.

The app's existing `loc`, `locStatus` and `locError` entry points remain in place.
The RPC library and daemon operations do not depend on the localization module.
Arbitrary torrent names, labels and tracker error messages are never translated;
only the known tracker `Success` result is localized.

## Adding another language

1. Add a file with a `LanguagePack`, using Hungarian source text as keys. Provide
   a native language name, a formatting locale and supported language codes.
2. Add an `AppLanguage` case and map it to that pack in `AppLanguage.pack`. Do not
   rename existing raw values: they are saved preferences.
3. Add its BCP-47 code to `CFBundleLocalizations` in `Scripts/build-app.sh`. This
   lets macOS recognize the supported language for standard system UI.
4. Add language-resolution and translation tests, and update the documented list
   of languages. No SwiftUI/RPC changes are needed for an ordinary new pack.

Missing translations fall back to English, then the source key. Status vocabulary
is separate because a settings tab named “Download” and a state “Downloading”
share the Hungarian key `Letöltés`. Verification progress is preserved exactly;
weekday labels use the selected pack's formatting locale.

Run `swift run LocalizationTests` and `swift run KitTests`, and build the app with
`swift build -c release --product TransmissionRemoteGUI`. The localization runner
checks every English key for nonempty Chinese coverage, existing English/Hungarian
values, fallback, system language/script matching, saved-preference compatibility,
runtime observation, all torrent statuses, verification percentages, weekdays,
notification strings and tracker diagnostics. It uses isolated UserDefaults,
needs no daemon, and runs in CI.
