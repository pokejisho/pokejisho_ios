import Foundation
import Combine

final class UserData: ObservableObject {
    @Published private(set) var favorites: Set<String>
    @Published private(set) var recents: [String]
    private let defaults = UserDefaults.standard

    init() {
        favorites = Set(defaults.stringArray(forKey: "favorites") ?? [])
        recents = defaults.stringArray(forKey: "recents") ?? []
    }

    func isFavorite(_ id: String) -> Bool { favorites.contains(id) }

    func toggleFavorite(_ id: String) {
        if favorites.contains(id) { favorites.remove(id) } else { favorites.insert(id) }
        defaults.set(Array(favorites), forKey: "favorites")
    }

    func removeFavorites(_ ids: [String]) {
        favorites.subtract(ids)
        defaults.set(Array(favorites), forKey: "favorites")
    }

    func addRecent(_ term: String) {
        let t = term.trimmingCharacters(in: .whitespaces)
        guard t.count >= 2 else { return }
        recents.removeAll { $0 == t }
        recents.insert(t, at: 0)
        if recents.count > 15 { recents = Array(recents.prefix(15)) }
        defaults.set(recents, forKey: "recents")
    }

    func removeRecents(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) where recents.indices.contains(index) {
            recents.remove(at: index)
        }
        defaults.set(recents, forKey: "recents")
    }
}
