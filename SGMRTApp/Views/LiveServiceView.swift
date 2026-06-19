import SwiftUI

struct LiveServiceView: View {
    let route: RouteResult
    let alerts: [TrainServiceAlert]
    let crowdDensity: [CrowdDensity]
    let isLoading: Bool
    let errorMessage: String?

    private var routeLines: Set<String> {
        Set(route.steps.map { $0.line.rawValue })
    }

    private var relevantAlerts: [TrainServiceAlert] {
        alerts.filter { alert in
            guard let line = alert.line else { return true }
            return routeLines.contains(line)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Live LTA context", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.headline)
                Spacer()
                if isLoading {
                    ProgressView()
                }
            }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            } else if relevantAlerts.isEmpty {
                Label("No route-line disruptions reported.", systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            } else {
                ForEach(relevantAlerts) { alert in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(alert.line ?? "Train") alert")
                            .font(.subheadline.weight(.semibold))
                        Text(alert.message?.content ?? alert.direction ?? "Service advisory available.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !crowdDensity.isEmpty {
                Divider()
                Text("Crowd density on route")
                    .font(.subheadline.weight(.semibold))
                ForEach(crowdDensity.prefix(8)) { item in
                    HStack {
                        Text(item.station)
                        Spacer()
                        Text(item.displayLevel)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.secondarySystemGroupedBackground), in: Capsule())
                    }
                    .font(.caption)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
