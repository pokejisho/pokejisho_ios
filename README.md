# PokéJisho

A native SwiftUI iOS app for looking up Pokémon names between Japanese and English.
Type a term and get live-filtered results, then open a detail screen enriched via
[PokéAPI](https://pokeapi.co). Includes favorites, recent searches, copy-to-clipboard, type
filtering, and an in-app language toggle (EN/JA).

The dictionary is bundled and works fully offline; PokéAPI is used only to enrich the detail screen.

## Structure

- **`PokeJishoKit/`** — Swift Package with all logic and the bundled dataset (no SwiftUI). Tests live here.
- **`PokéJisho/`** — the SwiftUI app target.

## Develop

Run the logic tests:

```bash
cd PokeJishoKit && swift test
```

Build the app:

```bash
xcodebuild -scheme "PokéJisho" -destination 'generic/platform=iOS Simulator' build
```

## Acknowledgements

Pokémon data via [PokéAPI](https://pokeapi.co). This is an unofficial fan project and is not
affiliated with Nintendo, Game Freak, or The Pokémon Company.
