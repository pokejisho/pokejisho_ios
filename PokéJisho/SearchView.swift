import SwiftUI
import AVFoundation
import PokeJishoKit

/// Wraps a captured image so it can drive an item-based presentation.
private struct CapturedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct SearchView: View {
    @StateObject private var vm: SearchViewModel
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var loc: LocalizationManager
    @State private var showSettings = false
    @State private var showCamera = false
    @State private var captured: CapturedImage?
    @State private var showCameraDeniedAlert = false
    @State private var pendingImage: UIImage?
    private let store: DictionaryStore

    init(store: DictionaryStore) {
        self.store = store
        _vm = StateObject(wrappedValue: SearchViewModel(store: store))
    }

    private var favoriteEntries: [DictionaryEntry] {
        store.entries(ids: userData.favorites).sorted { $0.english < $1.english }
    }

    private func startScan() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { showCamera = true } else { showCameraDeniedAlert = true }
                }
            }
        default:
            showCameraDeniedAlert = true
        }
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
                    Button { startScan() } label: { Image(systemName: "camera") }
                        .accessibilityLabel(loc.string("scan.button"))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                        .accessibilityLabel(loc.string("settings.title"))
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .fullScreenCover(isPresented: $showCamera, onDismiss: {
                if let image = pendingImage {
                    pendingImage = nil
                    captured = CapturedImage(image: image)
                }
            }) {
                CameraPicker(
                    onCapture: { image in
                        pendingImage = image
                        showCamera = false
                    },
                    onCancel: { showCamera = false }
                )
                .ignoresSafeArea()
            }
            .fullScreenCover(item: $captured) { item in
                TextSelectionView(
                    image: item.image,
                    onSearch: { text in
                        captured = nil
                        vm.query = text
                    },
                    onCancel: { captured = nil }
                )
            }
            .alert(loc.string("camera.denied.title"), isPresented: $showCameraDeniedAlert) {
                Button(loc.string("common.openSettings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(loc.string("common.cancel"), role: .cancel) {}
            } message: {
                Text(loc.string("camera.denied.message"))
            }
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
                HStack(alignment: .center, spacing: 4) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(loc.string("help.welcome"))
                            .font(.headline)
                        Text(loc.string("help.body"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    }
                    .overlay(alignment: .trailing) {
                        BubbleTail()
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 12, height: 18)
                            .offset(x: 11)
                    }

                    Image("Mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96)
                }
                .padding(.vertical, 8)
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

/// A small triangle whose apex points right, used as the speech bubble's tail toward Sagumi.
struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
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
