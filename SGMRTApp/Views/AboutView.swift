import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 10) {
                    Image(systemName: "tram.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.tint)
                    Text("SGMRT")
                        .font(.title.weight(.bold))
                    Text("Singapore MRT journey planner")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Version \(version) (\(build))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section("About") {
                Text("Plan the fastest MRT route between any two stations, browse every line and its stops, view the system map, and see live LTA service context. GPS can highlight your next stop while you ride.")
                    .font(.subheadline)
            }

            Section("Information") {
                LabeledContent("Version", value: "\(version) (\(build))")
                LabeledContent("Platform", value: "iOS 17+")
                Link(destination: URL(string: "https://github.com/alfredang/sgmrtapp")!) {
                    Label("Project page", systemImage: "link")
                }
                Link(destination: URL(string: "https://github.com/alfredang/sgmrtapp/issues")!) {
                    Label("Report an issue", systemImage: "exclamationmark.bubble")
                }
            }

            Section {
                Text("Developed by Tertiary Infotech Academy Pte. Ltd.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Public transport data from the Singapore Land Transport Authority (LTA DataMall).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } footer: {
                Text("© 2026 Tertiary Infotech Academy Pte. Ltd.")
            }
        }
    }
}
