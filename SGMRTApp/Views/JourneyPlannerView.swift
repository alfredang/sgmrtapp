import SwiftUI

struct JourneyPlannerView: View {
    @ObservedObject var viewModel: JourneyPlannerViewModel
    @State private var pickingStart = false
    @State private var pickingEnd = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                stationInputs

                Button {
                    viewModel.calculateRoute()
                    Task { await viewModel.refreshLiveData() }
                } label: {
                    Label("Find shortest route", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.start == nil || viewModel.end == nil)

                NearbyJourneyCard(viewModel: viewModel, location: viewModel.location)

                if let route = viewModel.route {
                    RouteSummaryView(route: route)
                    LiveServiceView(
                        route: route,
                        alerts: viewModel.alerts,
                        crowdDensity: viewModel.crowdForRoute(),
                        isLoading: viewModel.isLoadingLiveData,
                        errorMessage: viewModel.errorMessage
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.saveCurrentAsFavorite()
                } label: {
                    Image(systemName: viewModel.isCurrentRouteFavorite ? "star.fill" : "star")
                        .foregroundStyle(viewModel.isCurrentRouteFavorite ? Color.yellow : Color.accentColor)
                }
                .disabled(viewModel.start == nil || viewModel.end == nil)
                .accessibilityLabel("Save current route as favorite")
            }
        }
        .onAppear {
            viewModel.calculateRoute()
            Task { await viewModel.refreshLiveData() }
        }
        .sheet(isPresented: $pickingStart) {
            StationPickerView(title: "Start Station", stations: viewModel.stations, selection: $viewModel.start)
        }
        .sheet(isPresented: $pickingEnd) {
            StationPickerView(title: "End Station", stations: viewModel.stations, selection: $viewModel.end)
        }
    }

    private var stationInputs: some View {
        VStack(spacing: 12) {
            StationSelectButton(title: "Start", station: viewModel.start) {
                pickingStart = true
            }

            HStack {
                Divider()
                Button {
                    viewModel.swapStations()
                    Task { await viewModel.refreshLiveData() }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.headline)
                        .frame(width: 38, height: 38)
                }
                .buttonStyle(.bordered)
                Divider()
            }

            StationSelectButton(title: "End", station: viewModel.end) {
                pickingEnd = true
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct StationSelectButton: View {
    let title: String
    let station: Station?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: title == "Start" ? "location.circle.fill" : "mappin.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(station?.name ?? "Select station")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// GPS card: detects the rider's nearest station and flashes the next stop along the route.
private struct NearbyJourneyCard: View {
    @ObservedObject var viewModel: JourneyPlannerViewModel
    @ObservedObject var location: LocationManager
    @State private var flash = false

    private var enabled: Bool {
        location.authorization == .authorizedWhenInUse || location.authorization == .authorizedAlways
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Live position", systemImage: "location.fill")
                    .font(.headline)
                Spacer()
                if enabled && location.isTracking {
                    Image(systemName: "dot.radiowaves.left.and.right").foregroundStyle(.green)
                }
            }

            if !enabled {
                Text("Use GPS to find your nearest MRT station and flash your next stop.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button {
                    viewModel.startLocation()
                } label: {
                    Label("Enable location", systemImage: "location")
                }
                .buttonStyle(.bordered)
            } else if let nearest = viewModel.nearestStation {
                HStack(spacing: 10) {
                    Image(systemName: "smallcircle.filled.circle")
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nearest station")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(nearest.name).font(.headline)
                    }
                    if let meters = location.nearestDistanceMeters {
                        Spacer()
                        Text(meters < 1000 ? "\(Int(meters)) m" : String(format: "%.1f km", meters / 1000))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                if let next = viewModel.nextStationOnRoute {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Next stop").font(.caption).foregroundStyle(.secondary)
                            Text(next.name).font(.title3.weight(.bold))
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.orange.opacity(flash ? 0.28 : 0.08),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: flash)
                    .onAppear { flash = true }
                } else {
                    Text("Not on your current route — plan a route that passes your location to see the next stop.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                ProgressView("Locating…")
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

