import SwiftUI

struct OnboardingUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingUpsell = false

    var body: some View {
        Group {
            if !showingUpsell {
                PrimerView(showingUpsell: $showingUpsell, dismiss: dismiss)
            } else {
                UpsellView(dismiss: dismiss)
            }
        }
    }
}

// MARK: - Primer View
struct PrimerView: View {
    @Binding var showingUpsell: Bool
    let dismiss: DismissAction

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {
                    Section {
                        VStack(spacing: 24) {
                            Text("DAY ONE")
                                .font(.system(size: 13, weight: .medium))
                                .tracking(2)
                                .foregroundStyle(.primary)
                                .padding(.top, 12)

                            Text("The world's top-rated journaling app")
                                .font(.system(size: 28, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(Color.clear)

                    Section {
                        VStack(spacing: 12) {
                            // Star rating
                            HStack(spacing: 4) {
                                ForEach(0..<5) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.orange)
                                }
                            }

                            Text("4.8 Rating (176k Ratings)")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.clear)

                    Section {
                        AwardRow(icon: "apple.logo", title: "Apple App of the Year")
                        AwardRow(icon: "apple.logo", title: "Apple Design Award")
                        HStack(spacing: 12) {
                            Image(systemName: "laurel.leading")
                                .font(.system(size: 20))
                                .foregroundStyle(.secondary)
                            Text("Apple Editor's Choice")
                                .font(.system(size: 17))
                            Image(systemName: "laurel.trailing")
                                .font(.system(size: 20))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section {
                        VStack(spacing: 12) {
                            Text("\"Something so rare it feels almost sacred: A completely private digital space.\"")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .italic()

                            Text("— The New York Times")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.primary)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color(.systemGray6))

                    // Spacer for button area
                    Section {
                        Color.clear
                            .frame(height: 80)
                    }
                    .listRowBackground(Color.clear)
                }

                // Fixed button at bottom
                VStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            showingUpsell = true
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "44C0FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - Upsell View
struct UpsellView: View {
    let dismiss: DismissAction

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {
                    Section {
                        VStack(spacing: 24) {
                            Text("DAY ONE PREMIUM")
                                .font(.system(size: 13, weight: .medium))
                                .tracking(2)
                                .foregroundStyle(.primary)
                                .padding(.top, 12)

                            Text("Unlock the full power of Day One")
                                .font(.system(size: 28, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(Color.clear)

                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text("3.6 times more likely")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color(hex: "5B4FDB"))
                                Text(" to form a journaling habit with Premium")
                                    .font(.system(size: 17))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                    }

                    Section {
                        FeatureRow(icon: "photo.on.rectangle", title: "Unlimited photos & videos")
                        FeatureRow(icon: "rectangle.on.rectangle", title: "Unlimited devices")
                        FeatureRow(icon: "mic.fill", title: "Audio recording & transcription")
                    }

                    // Spacer for button area
                    Section {
                        Color.clear
                            .frame(height: 160)
                    }
                    .listRowBackground(Color.clear)
                }

                // Fixed buttons at bottom
                VStack(spacing: 12) {
                    Button(action: {
                        // TODO: Handle premium trial
                        dismiss()
                    }) {
                        VStack(spacing: 4) {
                            Text("Give Premium a Try")
                                .font(.system(size: 17, weight: .semibold))
                            Text("1 month free, cancel any time")
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "5B4FDB"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: {
                        // TODO: Continue with free plan
                        dismiss()
                    }) {
                        Text("Continue with Free Plan")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(hex: "5B4FDB"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "5B4FDB"), lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct AwardRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.system(size: 17))
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: "5B4FDB"))
            Text(title)
                .font(.system(size: 17))
        }
        .padding(.vertical, 4)
    }
}

#Preview("Primer") {
    OnboardingUpgradeView()
}
