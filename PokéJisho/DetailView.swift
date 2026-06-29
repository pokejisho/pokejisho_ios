import SwiftUI
import PokeJishoKit

struct DetailView: View {
    let entry: DictionaryEntry
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var loc: LocalizationManager
    @State private var apiDetail: PokeAPIDetail?
    @State private var loading = false
    @State private var safariURL: IdentifiableURL?
    @State private var copyTrigger = 0

    private static let service = PokeAPIService()

    private var bulbapediaURL: URL {
        let slug = entry.english.replacingOccurrences(of: " ", with: "_")
        return URL(string: "https://bulbapedia.bulbagarden.net/wiki/\(slug)")
            ?? URL(string: "https://bulbapedia.bulbagarden.net")!
    }
    private var pokewikiURL: URL {
        let encoded = entry.japanese.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? entry.japanese
        return URL(string: "https://wiki.pokemonwiki.com/wiki/\(encoded)")
            ?? URL(string: "https://wiki.pokemonwiki.com")!
    }

    var body: some View {
        List {
            Section {
                if loading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                }
                if let sprite = apiDetail?.spriteURL {
                    AsyncImage(url: sprite) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                }
                LabeledContent("English", value: entry.english)
                LabeledContent("日本語", value: entry.japanese)
                LabeledContent(loc.string("detail.romaji"), value: entry.romaji)
            }

            if let facts = apiDetail?.facts, !facts.isEmpty {
                Section {
                    ForEach(facts) { fact in
                        LabeledContent(fact.label, value: fact.value)
                    }
                }
            }

            if let flavor = apiDetail?.flavorText, !flavor.isEmpty {
                Section { Text(flavor) }
            }

            Section(loc.string("detail.learnMore")) {
                Button(loc.string("detail.bulbapedia")) { safariURL = IdentifiableURL(url: bulbapediaURL) }
                Button(loc.string("detail.pokewiki")) { safariURL = IdentifiableURL(url: pokewikiURL) }
            }
        }
        .navigationTitle(entry.english)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    UIPasteboard.general.string = "\(entry.english) / \(entry.japanese)"
                    copyTrigger += 1
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .accessibilityLabel(loc.string("detail.copy"))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    userData.toggleFavorite(entry.id)
                } label: {
                    Image(systemName: userData.isFavorite(entry.id) ? "star.fill" : "star")
                }
                .accessibilityLabel(loc.string(userData.isFavorite(entry.id) ? "favorite.remove" : "favorite.add"))
            }
        }
        .sheet(item: $safariURL) { item in
            SafariView(url: item.url).ignoresSafeArea()
        }
        .task(id: entry.id) {
            loading = true
            apiDetail = await Self.service.detail(for: entry)
            loading = false
        }
        .sensoryFeedback(.success, trigger: copyTrigger)
        .sensoryFeedback(.impact(weight: .light), trigger: userData.isFavorite(entry.id))
    }
}
