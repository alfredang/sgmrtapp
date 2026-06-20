import Foundation

/// Persists a single favorite journey (start + end station ids) in `UserDefaults`, so the
/// planner can auto-load it on launch.
struct FavoritesStore {
    private enum Key {
        static let start = "favorite.start.station.id"
        static let end = "favorite.end.station.id"
        static let autoLoad = "favorite.autoLoad.enabled"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: Key.autoLoad) == nil {
            defaults.set(true, forKey: Key.autoLoad)
        }
    }

    var favoriteStartID: String? { defaults.string(forKey: Key.start) }
    var favoriteEndID: String? { defaults.string(forKey: Key.end) }
    var hasFavorite: Bool { favoriteStartID != nil && favoriteEndID != nil }

    var autoLoadEnabled: Bool {
        get { defaults.bool(forKey: Key.autoLoad) }
        nonmutating set { defaults.set(newValue, forKey: Key.autoLoad) }
    }

    func save(startID: String, endID: String) {
        defaults.set(startID, forKey: Key.start)
        defaults.set(endID, forKey: Key.end)
    }

    func clear() {
        defaults.removeObject(forKey: Key.start)
        defaults.removeObject(forKey: Key.end)
    }
}
