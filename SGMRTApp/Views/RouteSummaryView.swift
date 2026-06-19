import SwiftUI

struct RouteSummaryView: View {
    let route: RouteResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(route.estimatedMinutes) min")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    Text("\(route.stations.count) stations • \(route.transferCount) transfers")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundStyle(.tint)
            }

            ForEach(route.steps) { step in
                HStack(alignment: .top, spacing: 12) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(step.line.tint)
                        .frame(width: 6)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(step.line.rawValue)
                                .font(.headline)
                            Text(step.line.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(step.minutes) min")
                                .font(.subheadline.weight(.semibold))
                        }
                        Text("\(step.stations.first?.name ?? "") to \(step.stations.last?.name ?? "")")
                            .font(.subheadline)
                        Text(step.stations.map(\.name).joined(separator: "  ·  "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

