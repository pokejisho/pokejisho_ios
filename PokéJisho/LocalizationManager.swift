import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case system, en, ja
    var id: String { rawValue }
}

final class LocalizationManager: ObservableObject {
    @AppStorage("appLanguage") private var stored: String = AppLanguage.system.rawValue

    var language: AppLanguage {
        get { AppLanguage(rawValue: stored) ?? .system }
        set { stored = newValue.rawValue; objectWillChange.send() }
    }

    private var bundle: Bundle {
        let code: String?
        switch language {
        case .system: code = nil
        case .en: code = "en"
        case .ja: code = "ja"
        }
        guard let code,
              let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let b = Bundle(path: path) else { return .main }
        return b
    }

    func string(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
