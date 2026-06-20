import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = JourneyPlannerViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                JourneyPlannerView(viewModel: viewModel)
                    .navigationTitle("SG MRT")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Route", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
            }

            NavigationStack {
                LinesView(network: viewModel.network)
                    .navigationTitle("Lines")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Lines", systemImage: "tram.fill")
            }

            NavigationStack {
                MapPDFView()
                    .navigationTitle("MRT Map")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                SettingsView(viewModel: viewModel)
                    .navigationTitle("Favorites")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Favorites", systemImage: "star")
            }

            NavigationStack {
                AboutView()
                    .navigationTitle("About")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
    }
}

