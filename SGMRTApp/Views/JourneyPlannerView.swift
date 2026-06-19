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

