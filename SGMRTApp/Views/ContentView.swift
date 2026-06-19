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
                MapPDFView()
                    .navigationTitle("MRT Map")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
        }
    }
}

