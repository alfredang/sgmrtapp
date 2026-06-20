import SwiftUI

struct LinesView: View {
    let network: MRTNetwork

    /// The lines riders pick from (branches are folded into their parent line).
    private let displayLines: [MRTLine] = [.nsl, .ewl, .nel, .ccl, .dtl, .tel]

    var body: some View {
        List(displayLines, id: \.self) { line in
            NavigationLink {
                LineStationsView(line: line, stations: network.lineStations[line] ?? [])
            } label: {
                HStack(spacing: 12) {
                    Text(line.rawValue)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 28)
                        .background(line.tint, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(line.name)
                            .font(.headline)
                        Text("\(network.lineStations[line]?.count ?? 0) stations")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct LineStationsView: View {
    let line: MRTLine
    let stations: [Station]

    var body: some View {
        List {
            Section {
                ForEach(Array(stations.enumerated()), id: \.element.id) { index, station in
                    StationRow(line: line, station: station, isFirst: index == 0, isLast: index == stations.count - 1)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            } header: {
                Text("\(stations.count) stations · \(interchangeCount) interchanges")
            }
        }
        .listStyle(.plain)
        .navigationTitle(line.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var interchangeCount: Int {
        stations.filter { $0.lines.count > 1 }.count
    }
}

private struct StationRow: View {
    let line: MRTLine
    let station: Station
    let isFirst: Bool
    let isLast: Bool

    private var connectingLines: [MRTLine] {
        station.sortedLines.filter { $0 != line }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Line track with a node dot, plus an interchange ring for transfer stations.
            ZStack {
                VStack(spacing: 0) {
                    Rectangle().fill(isFirst ? .clear : line.tint).frame(width: 4)
                    Rectangle().fill(isLast ? .clear : line.tint).frame(width: 4)
                }
                Circle()
                    .stroke(line.tint, lineWidth: connectingLines.isEmpty ? 4 : 5)
                    .background(Circle().fill(Color(.systemBackground)))
                    .frame(width: connectingLines.isEmpty ? 14 : 20, height: connectingLines.isEmpty ? 14 : 20)
            }
            .frame(width: 24)

            VStack(alignment: .leading, spacing: 5) {
                Text(station.name)
                    .font(.body.weight(connectingLines.isEmpty ? .regular : .semibold))
                if !connectingLines.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.swap")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        LineBadges(lines: connectingLines)
                    }
                }
            }
            Spacer()
        }
        .frame(minHeight: 52)
        .contentShape(Rectangle())
    }
}
