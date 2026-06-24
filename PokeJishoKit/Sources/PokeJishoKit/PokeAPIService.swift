import Foundation

public actor PokeAPIService {
    private let session: URLSession
    private var cache: [String: PokeAPIDetail] = [:]
    private let base = URL(string: "https://pokeapi.co/api/v2/")!

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func detail(for entry: DictionaryEntry) async -> PokeAPIDetail? {
        guard let resource = PokeAPIResource(type: entry.type) else { return nil }
        let slug = pokeAPISlug(for: entry.english)
        let key = "\(resource.rawValue)/\(slug)"
        if let cached = cache[key] { return cached }

        let url = base.appendingPathComponent(resource.rawValue).appendingPathComponent(slug)
        guard let (data, response) = try? await session.data(from: url),
              let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }

        let detail = Self.parse(resource: resource, json: json)
        cache[key] = detail
        return detail
    }

    static func parse(resource: PokeAPIResource, json: [String: Any]) -> PokeAPIDetail {
        var spriteURL: URL?
        var facts: [PokeAPIDetail.Fact] = []

        if let sprites = json["sprites"] as? [String: Any],
           let front = sprites["front_default"] as? String {
            spriteURL = URL(string: front)
        }
        if let types = json["types"] as? [[String: Any]] {
            let names = types.compactMap { ($0["type"] as? [String: Any])?["name"] as? String }
            if !names.isEmpty { facts.append(.init("Type", names.joined(separator: ", "))) }
        }
        if let height = json["height"] as? Int { facts.append(.init("Height", "\(Double(height) / 10) m")) }
        if let weight = json["weight"] as? Int { facts.append(.init("Weight", "\(Double(weight) / 10) kg")) }
        if let power = json["power"] as? Int { facts.append(.init("Power", "\(power)")) }
        if let pp = json["pp"] as? Int { facts.append(.init("PP", "\(pp)")) }
        if let accuracy = json["accuracy"] as? Int { facts.append(.init("Accuracy", "\(accuracy)")) }

        let flavor = (json["flavor_text_entries"] as? [[String: Any]])?
            .first(where: { ($0["language"] as? [String: Any])?["name"] as? String == "en" })?["flavor_text"] as? String

        return PokeAPIDetail(
            spriteURL: spriteURL,
            facts: facts,
            flavorText: flavor?.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\u{0C}", with: " ")
        )
    }
}
