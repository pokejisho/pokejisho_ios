import Testing
import Foundation
@testable import PokeJishoKit

final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var responder: ((URLRequest) -> (Int, Data))?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for r: URLRequest) -> URLRequest { r }
    override func startLoading() {
        let (code, data) = Self.responder?(request) ?? (404, Data())
        let resp = HTTPURLResponse(url: request.url!, statusCode: code, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

private func mockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

@Test func fetchesPokemonDetail() async {
    MockURLProtocol.responder = { _ in
        let json = #"{"height":7,"weight":69,"sprites":{"front_default":"https://img/1.png"},"types":[{"type":{"name":"grass"}}]}"#
        return (200, json.data(using: .utf8)!)
    }
    let service = PokeAPIService(session: mockSession())
    let entry = DictionaryEntry(type: .pokemon, english: "Bulbasaur", japanese: "フシギダネ", katakana: "フシギダネ", romaji: "fushigidane")
    let detail = await service.detail(for: entry)
    #expect(detail != nil)
    #expect(detail?.spriteURL?.absoluteString == "https://img/1.png")
}

@Test func unsupportedTypeReturnsNilWithoutNetwork() async {
    let service = PokeAPIService(session: mockSession())
    let entry = DictionaryEntry(type: .character, english: "April", japanese: "アンリ", katakana: "アンリ", romaji: "anri")
    let detail = await service.detail(for: entry)
    #expect(detail == nil)
}
