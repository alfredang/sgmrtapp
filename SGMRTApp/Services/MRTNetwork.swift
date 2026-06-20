import Foundation

struct MRTNetwork {
    let stations: [Station]
    let adjacency: [String: [TrackEdge]]
    /// Stations in running order for each line (the sequence trains actually call at).
    let lineStations: [MRTLine: [Station]]

    init() {
        var builder = NetworkBuilder()
        builder.add(.ewl, [
            "Pasir Ris", "Tampines", "Simei", "Tanah Merah", "Bedok", "Kembangan", "Eunos", "Paya Lebar",
            "Aljunied", "Kallang", "Lavender", "Bugis", "City Hall", "Raffles Place", "Tanjong Pagar",
            "Outram Park", "Tiong Bahru", "Redhill", "Queenstown", "Commonwealth", "Buona Vista", "Dover",
            "Clementi", "Jurong East", "Chinese Garden", "Lakeside", "Boon Lay", "Pioneer", "Joo Koon",
            "Gul Circle", "Tuas Crescent", "Tuas West Road", "Tuas Link"
        ])
        builder.add(.cgl, ["Tanah Merah", "Expo", "Changi Airport"])
        builder.add(.nsl, [
            "Jurong East", "Bukit Batok", "Bukit Gombak", "Choa Chu Kang", "Yew Tee", "Kranji", "Marsiling",
            "Woodlands", "Admiralty", "Sembawang", "Canberra", "Yishun", "Khatib", "Yio Chu Kang",
            "Ang Mo Kio", "Bishan", "Braddell", "Toa Payoh", "Novena", "Newton", "Orchard", "Somerset",
            "Dhoby Ghaut", "City Hall", "Raffles Place", "Marina Bay", "Marina South Pier"
        ])
        builder.add(.nel, [
            "HarbourFront", "Outram Park", "Chinatown", "Clarke Quay", "Dhoby Ghaut", "Little India",
            "Farrer Park", "Boon Keng", "Potong Pasir", "Woodleigh", "Serangoon", "Kovan", "Hougang",
            "Buangkok", "Sengkang", "Punggol", "Punggol Coast"
        ])
        builder.add(.ccl, [
            "Dhoby Ghaut", "Bras Basah", "Esplanade", "Promenade", "Nicoll Highway", "Stadium", "Mountbatten",
            "Dakota", "Paya Lebar", "MacPherson", "Tai Seng", "Bartley", "Serangoon", "Lorong Chuan",
            "Bishan", "Marymount", "Caldecott", "Botanic Gardens", "Farrer Road", "Holland Village",
            "Buona Vista", "one-north", "Kent Ridge", "Haw Par Villa", "Pasir Panjang", "Labrador Park",
            "Telok Blangah", "HarbourFront"
        ])
        builder.add(.cel, ["Promenade", "Bayfront", "Marina Bay"])
        builder.add(.dtl, [
            "Bukit Panjang", "Cashew", "Hillview", "Hume", "Beauty World", "King Albert Park", "Sixth Avenue",
            "Tan Kah Kee", "Botanic Gardens", "Stevens", "Newton", "Little India", "Rochor", "Bugis",
            "Promenade", "Bayfront", "Downtown", "Telok Ayer", "Chinatown", "Fort Canning", "Bencoolen",
            "Jalan Besar", "Bendemeer", "Geylang Bahru", "Mattar", "MacPherson", "Ubi", "Kaki Bukit",
            "Bedok North", "Bedok Reservoir", "Tampines West", "Tampines", "Tampines East", "Upper Changi", "Expo"
        ])
        builder.add(.tel, [
            "Woodlands North", "Woodlands", "Woodlands South", "Springleaf", "Lentor", "Mayflower", "Bright Hill",
            "Upper Thomson", "Caldecott", "Stevens", "Napier", "Orchard Boulevard", "Orchard", "Great World",
            "Havelock", "Outram Park", "Maxwell", "Shenton Way", "Marina Bay", "Gardens by the Bay",
            "Tanjong Rhu", "Katong Park", "Tanjong Katong", "Marine Parade", "Marine Terrace", "Siglap", "Bayshore"
        ])

        let byName = builder.stationsByName
        stations = byName.values.sorted { $0.name < $1.name }
        adjacency = builder.adjacency
        lineStations = builder.lineOrder.reduce(into: [:]) { result, entry in
            result[entry.key] = entry.value.compactMap { byName[$0] }
        }
    }
}

private struct NetworkBuilder {
    var stationsByName: [String: Station] = [:]
    var adjacency: [String: [TrackEdge]] = [:]
    /// Ordered station names per line, preserved as added.
    var lineOrder: [MRTLine: [String]] = [:]

    mutating func add(_ line: MRTLine, _ names: [String]) {
        for name in names {
            let id = name.lowercased().replacingOccurrences(of: " ", with: "-")
            let existing = stationsByName[name]
            var lines = existing?.lines ?? []
            lines.insert(line)
            stationsByName[name] = Station(id: id, name: name, lines: lines)
        }

        // The Changi Airport branch (CGL) is operationally part of the East West Line.
        let key: MRTLine = line == .cgl ? .ewl : (line == .cel ? .ccl : line)
        lineOrder[key, default: []].append(contentsOf: names.filter { !(lineOrder[key]?.contains($0) ?? false) })

        for pair in zip(names, names.dropFirst()) {
            addEdge(from: pair.0, to: pair.1, line: line)
            addEdge(from: pair.1, to: pair.0, line: line)
        }
    }

    private mutating func addEdge(from: String, to: String, line: MRTLine) {
        let fromID = from.lowercased().replacingOccurrences(of: " ", with: "-")
        let toID = to.lowercased().replacingOccurrences(of: " ", with: "-")
        let minutes = (from == "Changi Airport" || to == "Changi Airport") ? 6 : 2
        adjacency[fromID, default: []].append(TrackEdge(from: fromID, to: toID, line: line, minutes: minutes))
    }
}

