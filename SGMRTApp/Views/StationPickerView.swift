import SwiftUI

struct StationPickerView: View {
    let title: String
    let stations: [Station]
    @Binding var selection: Station?
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var filteredStations: [Station] {
        guard !query.isEmpty else { return stations }
        return stations.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List(filteredStations) { station in
                Button {
                    selection = station
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(station.name)
                                .foregroundStyle(.primary)
                            LineBadges(lines: station.sortedLines)
                        }
                        Spacer()
                        if selection == station {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search station")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct LineBadges: View {
    let lines: [MRTLine]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(lines, id: \.self) { line in
                Text(line.rawValue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(line.tint, in: Capsule())
            }
        }
    }
}

