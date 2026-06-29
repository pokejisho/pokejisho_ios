import SwiftUI
import Combine

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, dark, light
    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }
}

final class AppearanceManager: ObservableObject {
    @AppStorage("appAppearance") private var stored: String = AppAppearance.system.rawValue

    var appearance: AppAppearance {
        get { AppAppearance(rawValue: stored) ?? .system }
        set { stored = newValue.rawValue; objectWillChange.send() }
    }
}
