import SwiftUI

struct StravaIntegrationView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            // Gray background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Strava logo
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(hex: "FC4C02"))
                        .frame(width: 88, height: 88)
                        .overlay(
                            // Strava logo placeholder - using mountain symbol
                            Image(systemName: "mountain.2.fill")
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                        .padding(.top, 20)

                    // Description
                    Text("Sign into Strava to connect your account to Day One and never miss capturing your fitness achievements and milestones.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)

                    // Features list - white inset grouped card
                    VStack(spacing: 0) {
                        StravaFeatureRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Smart Sync",
                            description: "Automatically syncs your entire Strava activity history into Day One."
                        )

                        StravaFeatureRow(
                            icon: "figure.run",
                            title: "Activity Details",
                            description: "Each entry includes the activity's title, description, and private notes."
                        )

                        StravaFeatureRow(
                            icon: "cloud.sun.fill",
                            title: "Metadata Capture",
                            description: "Captures location and weather details for each workout."
                        )

                        StravaFeatureRow(
                            icon: "map.fill",
                            title: "Activity Map",
                            description: "Displays a rich map of your route or activity."
                        )

                        StravaFeatureRow(
                            icon: "chart.xyaxis.line",
                            title: "Media and Stats",
                            description: "Includes all media and activity stats from Strava.",
                            isLast: true
                        )
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    Spacer(minLength: 100)
                }
            }

            // Connect button at bottom
            VStack(spacing: 0) {
                Button {
                    // TODO: Implement Strava OAuth flow
                } label: {
                    HStack(spacing: 8) {
                        Text("CONNECT WITH")
                            .font(.system(size: 17, weight: .bold))
                        Text("STRAVA")
                            .font(.system(size: 17, weight: .heavy))
                            .tracking(0.5)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(hex: "FC4C02"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Strava")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .fontWeight(.medium)
            }
        }
    }
}

// MARK: - Strava Feature Row
struct StravaFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    var isLast: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Icon
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.primary)
                    )

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            if !isLast {
                Divider()
                    .padding(.leading, 92)
            }
        }
    }
}

#Preview {
    NavigationStack {
        StravaIntegrationView()
    }
}
