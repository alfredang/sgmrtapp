import Foundation

struct RoutePlanner {
    private let network: MRTNetwork
    private let transferPenalty = 4

    init(network: MRTNetwork) {
        self.network = network
    }

    func shortestRoute(from origin: Station, to destination: Station) -> RouteResult? {
        guard origin.id != destination.id else {
            return RouteResult(stations: [origin], steps: [], estimatedMinutes: 0, transferCount: 0)
        }

        var frontier: [State] = [State(stationID: origin.id, line: nil, cost: 0)]
        var best: [StateKey: Int] = [StateKey(stationID: origin.id, line: nil): 0]
        var previous: [StateKey: (StateKey, TrackEdge)] = [:]
        var finalKey: StateKey?

        while !frontier.isEmpty {
            frontier.sort { $0.cost < $1.cost }
            let current = frontier.removeFirst()
            let currentKey = StateKey(stationID: current.stationID, line: current.line)
            guard current.cost == best[currentKey] else { continue }

            if current.stationID == destination.id {
                finalKey = currentKey
                break
            }

            for edge in network.adjacency[current.stationID, default: []] {
                let penalty = current.line == nil || current.line == edge.line ? 0 : transferPenalty
                let nextCost = current.cost + edge.minutes + penalty
                let nextKey = StateKey(stationID: edge.to, line: edge.line)
                if nextCost < best[nextKey, default: Int.max] {
                    best[nextKey] = nextCost
                    previous[nextKey] = (currentKey, edge)
                    frontier.append(State(stationID: edge.to, line: edge.line, cost: nextCost))
                }
            }
        }

        guard let finalKey, let minutes = best[finalKey] else { return nil }
        let edges = reconstructEdges(finalKey: finalKey, previous: previous)
        let stationLookup = Dictionary(uniqueKeysWithValues: network.stations.map { ($0.id, $0) })
        let routeStations = [origin] + edges.compactMap { stationLookup[$0.to] }
        let steps = makeSteps(edges: edges, routeStations: routeStations)
        let transfers = max(0, steps.count - 1)
        return RouteResult(stations: routeStations, steps: steps, estimatedMinutes: minutes, transferCount: transfers)
    }

    private func reconstructEdges(finalKey: StateKey, previous: [StateKey: (StateKey, TrackEdge)]) -> [TrackEdge] {
        var key = finalKey
        var edges: [TrackEdge] = []
        while let item = previous[key] {
            edges.append(item.1)
            key = item.0
        }
        return edges.reversed()
    }

    private func makeSteps(edges: [TrackEdge], routeStations: [Station]) -> [RouteStep] {
        guard !edges.isEmpty else { return [] }
        var steps: [RouteStep] = []
        var currentLine = edges[0].line
        var currentStations: [Station] = [routeStations[0]]
        var currentMinutes = 0

        for index in edges.indices {
            let edge = edges[index]
            let nextStation = routeStations[index + 1]
            if edge.line != currentLine {
                steps.append(RouteStep(line: currentLine, stations: currentStations, minutes: currentMinutes))
                currentLine = edge.line
                currentStations = [routeStations[index]]
                currentMinutes = 0
            }
            currentStations.append(nextStation)
            currentMinutes += edge.minutes
        }

        steps.append(RouteStep(line: currentLine, stations: currentStations, minutes: currentMinutes))
        return steps
    }
}

private struct State: Hashable {
    let stationID: String
    let line: MRTLine?
    let cost: Int
}

private struct StateKey: Hashable {
    let stationID: String
    let line: MRTLine?
}

