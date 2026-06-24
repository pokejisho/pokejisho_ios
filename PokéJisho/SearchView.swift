import SwiftUI
import PokeJishoKit

struct SearchView: View {
    @StateObject private var vm: SearchViewModel
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var loc: LocalizationManager
    @State private var showSettings = false
    private let store: DictionaryStore

    init(store: DictionaryStore) {
        self.store = store
        _vm = StateObject(wrappedValue: SearchViewModel(store: store))
    }

    private var favoriteEntries: [DictionaryEntry] {
        store.entries(ids: userData.favorites).sorted { $0.english < $1.english }
    }

    var body: some View {
        NavigationStack {
            Group {
                if !vm.hasQuery {
                    HelpView(favorites: favoriteEntries,
                             recents: userData.recents,
                             onSelectRecent: { vm.query = $0 },
                             onDeleteRecents: { userData.removeRecents(at: $0) },
                             onDeleteFavorites: { offsets in
                                 userData.removeFavorites(offsets.map { favoriteEntries[$0].id })
                             })
                } else if vm.results.isEmpty {
                    NoResultsView()
                } else {
                    resultsList
                }
            }
            .navigationTitle(loc.string("app.name"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { filterMenu }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                        .accessibilityLabel(loc.string("settings.title"))
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
        }
        .searchable(text: $vm.query, prompt: loc.string("search.placeholder"))
    }

    private var filterMenu: some View {
        Menu {
            Button {
                vm.filter = nil
            } label: {
                Label(loc.string("filter.all"), systemImage: vm.filter == nil ? "checkmark" : "")
            }
            ForEach(EntryType.allCases, id: \.self) { type in
                Button {
                    vm.filter = type
                } label: {
                    Label(loc.string("type.\(type.rawValue)"),
                          systemImage: vm.filter == type ? "checkmark" : "")
                }
            }
        } label: {
            Image(systemName: vm.filter == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityLabel(loc.string("filter.title"))
    }

    private var resultsList: some View {
        List {
            if !vm.results.priority.isEmpty {
                Section {
                    ForEach(vm.results.priority) { row($0) }
                }
            }
            if !vm.results.results.isEmpty {
                Section {
                    ForEach(vm.results.results) { row($0) }
                }
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
    }

    private func row(_ entry: DictionaryEntry) -> some View {
        NavigationLink {
            DetailView(entry: entry)
                .onAppear { userData.addRecent(vm.query) }
        } label: {
            EntryRow(entry: entry)
        }
    }
}

struct HelpView: View {
    let favorites: [DictionaryEntry]
    let recents: [String]
    let onSelectRecent: (String) -> Void
    let onDeleteRecents: (IndexSet) -> Void
    let onDeleteFavorites: (IndexSet) -> Void
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image("Mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                    Text(loc.string("help.welcome")).font(.headline)
                    Text(loc.string("help.body"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if !favorites.isEmpty {
                Section(loc.string("favorites.title")) {
                    ForEach(favorites) { entry in
                        NavigationLink {
                            DetailView(entry: entry)
                        } label: {
                            EntryRow(entry: entry)
                        }
                    }
                    .onDelete(perform: onDeleteFavorites)
                }
            }

            if !recents.isEmpty {
                Section(loc.string("recent.title")) {
                    ForEach(recents, id: \.self) { term in
                        Button {
                            onSelectRecent(term)
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text(term)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: onDeleteRecents)
                }
            }
        }
        .listStyle(.plain)
    }
}

struct NoResultsView: View {
    @EnvironmentObject var loc: LocalizationManager
    var body: some View {
        ContentUnavailableView {
            Label(loc.string("results.none.title"), systemImage: "magnifyingglass")
        } description: {
            Text(loc.string("results.none"))
        }
    }
}
