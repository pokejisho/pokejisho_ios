import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject var appearance: AppearanceManager
    @Environment(\.dismiss) private var dismiss

    private var currentYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(loc.string("settings.display")) {
                    Picker(loc.string("settings.appearance"), selection: Binding(
                        get: { appearance.appearance },
                        set: { appearance.appearance = $0 }
                    )) {
                        Text(loc.string("settings.appearance.system")).tag(AppAppearance.system)
                        Text(loc.string("settings.appearance.dark")).tag(AppAppearance.dark)
                        Text(loc.string("settings.appearance.light")).tag(AppAppearance.light)
                    }

                    Picker(loc.string("settings.language"), selection: Binding(
                        get: { loc.language },
                        set: { loc.language = $0 }
                    )) {
                        Text(loc.string("settings.language.system")).tag(AppLanguage.system)
                        Text("English").tag(AppLanguage.en)
                        Text("日本語").tag(AppLanguage.ja)
                    }
                }

                Section(loc.string("about.title")) {
                    Text(loc.string("about.fansite"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(loc.string("about.license"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(String(format: loc.string("about.copyright"), currentYear))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(loc.string("about.pokeapi"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Link(loc.string("about.pokeapi.link"),
                         destination: URL(string: "https://pokeapi.co")!)
                        .font(.footnote)
                    Link(loc.string("about.github"),
                         destination: URL(string: "https://github.com/pokejisho/pokejisho_ios")!)
                        .font(.footnote)
                    LabeledContent(loc.string("settings.version"), value: appVersion)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(loc.string("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                }
            }
        }
    }
}
