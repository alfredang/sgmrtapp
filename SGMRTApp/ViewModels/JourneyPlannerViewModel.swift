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

    let network = MRTNetwork()
    private let client = LTADataMallClient()
    private lazy var planner = RoutePlanner(network: network)

    var stations: [Station] { network.stations }

    init() {
        start = network.stations.first { $0.name == "Jurong East" }
        end = network.stations.first { $0.name == "Marina Bay" }
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
}
