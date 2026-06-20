import Foundation

@MainActor
final class JourneyPlannerViewModel: ObservableObject {
    @Published var start: Station?
    @Published var end: Station?
    @Published private(set) var route: RouteResult?
    @Published private(set) var alerts: [TrainServiceAlert] = []
    @Published private(set) var crowdDensity: [CrowdDensity] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoadingLiveData = false
    @Published private(set) var favoriteSaved = false

    let network = MRTNetwork()
    let location = LocationManager()
    private let client = LTADataMallClient()
    private let favorites = FavoritesStore()
    private lazy var planner = RoutePlanner(network: network)
    private lazy var stationsByID = Dictionary(uniqueKeysWithValues: network.stations.map { ($0.id, $0) })

    var stations: [Station] { network.stations }

    init() {
        let defaultStart = network.stations.first { $0.name == "Jurong East" }
        let defaultEnd = network.stations.first { $0.name == "Marina Bay" }
        if favorites.autoLoadEnabled,
           let s = favorites.favoriteStartID.flatMap({ stationsByID[$0] }),
           let e = favorites.favoriteEndID.flatMap({ stationsByID[$0] }) {
            start = s
            end = e
        } else {
            start = defaultStart
            end = defaultEnd
        }
    }

    func calculateRoute() {
        guard let start, let end else {
            route = nil
            return
        }
        route = planner.shortestRoute(from: start, to: end)
    }

    func swapStations() {
        let oldStart = start
        start = end
        end = oldStart
        calculateRoute()
    }

    func refreshLiveData() async {
        guard let route else { return }
        isLoadingLiveData = true
        errorMessage = nil
        defer { isLoadingLiveData = false }

        do {
            async let fetchedAlerts = client.fetchTrainServiceAlerts()
            let routeLines = Array(Set(route.steps.map(\.line))).prefix(3)
            var crowds: [CrowdDensity] = []
            for line in routeLines {
                crowds += (try? await client.fetchCrowdDensity(for: line)) ?? []
            }
            alerts = try await fetchedAlerts
            crowdDensity = crowds
        } catch {
            errorMessage = "Live LTA data could not be loaded. Route estimates are still available."
        }
    }

    func crowdForRoute() -> [CrowdDensity] {
        Array(crowdDensity.prefix(12))
    }

    // MARK: - Favorites

    var hasFavorite: Bool { favorites.hasFavorite }

    var isCurrentRouteFavorite: Bool {
        favorites.favoriteStartID == start?.id && favorites.favoriteEndID == end?.id
    }

    func saveCurrentAsFavorite() {
        guard let start, let end else { return }
        favorites.save(startID: start.id, endID: end.id)
        favoriteSaved = true
        objectWillChange.send()
    }

    func clearFavorite() {
        favorites.clear()
        favoriteSaved = false
        objectWillChange.send()
    }

    func loadFavorite() {
        guard let s = favorites.favoriteStartID.flatMap({ stationsByID[$0] }),
              let e = favorites.favoriteEndID.flatMap({ stationsByID[$0] }) else { return }
        start = s
        end = e
        calculateRoute()
    }

    var autoLoadFavorite: Bool {
        get { favorites.autoLoadEnabled }
        set { favorites.autoLoadEnabled = newValue; objectWillChange.send() }
    }

    func favoriteDescription() -> String? {
        guard let s = favorites.favoriteStartID.flatMap({ stationsByID[$0] }),
              let e = favorites.favoriteEndID.flatMap({ stationsByID[$0] }) else { return nil }
        return "\(s.name) → \(e.name)"
    }

    // MARK: - GPS nearest / next station

    func startLocation() { location.start() }

    var nearestStation: Station? {
        location.nearestStationID.flatMap { stationsByID[$0] }
    }

    /// The station immediately after the rider's nearest station along the current route — the
    /// "next stop". `nil` when GPS is off, no route is set, or the nearest station is the
    /// destination / not on the route.
    var nextStationOnRoute: Station? {
        guard let route, let nearestID = location.nearestStationID else { return nil }
        let ids = route.stations.map(\.id)
        guard let index = ids.firstIndex(of: nearestID), index + 1 < route.stations.count else { return nil }
        return route.stations[index + 1]
    }
}
