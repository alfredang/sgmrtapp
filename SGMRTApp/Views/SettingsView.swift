import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: JourneyPlannerViewModel

    var body: some View {
        Form {
            Section {
                if let favorite = viewModel.favoriteDescription() {
                    HStack {
                        Image(systemName: "star.fill").foregroundStyle(.yellow)
                        Text(favorite).font(.headline)
                    }
                    Button {
                        viewModel.loadFavorite()
                    } label: {
                        Label("Load favorite into planner", systemImage: "arrow.down.circle")
                    }
                    Button(role: .destructive) {
                        viewModel.clearFavorite()
                    } label: {
                        Label("Remove favorite", systemImage: "trash")
                    }
                } else {
                    Text("No favorite saved yet.")
                        .foregroundStyle(.secondary)
                    Text("On the Route tab, set your start and end stations and tap the ★ to save them here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Favorite journey")
            } footer: {
                Text("Save the journey you take most often for one-tap planning.")
            }

            Section {
                Toggle("Auto-load favorite on launch", isOn: Binding(
                    get: { viewModel.autoLoadFavorite },
                    set: { viewModel.autoLoadFavorite = $0 }
                ))
                .disabled(!viewModel.hasFavorite)
            } footer: {
                Text("When on, the app opens with your favorite start and end stations already selected.")
            }

            Section {
                Button {
                    viewModel.saveCurrentAsFavorite()
                } label: {
                    Label("Save current route as favorite", systemImage: "star")
                }
                .disabled(viewModel.start == nil || viewModel.end == nil)
                if let s = viewModel.start, let e = viewModel.end {
                    Text("\(s.name) → \(e.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Current planner selection")
            }
        }
    }
}
