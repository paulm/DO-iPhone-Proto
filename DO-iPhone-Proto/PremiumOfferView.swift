import SwiftUI

struct PremiumOfferView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {

                    Section {
                        VStack(spacing: 12) {
                            Text("Limited-Time Offer")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color(hex: "5B4FDB"))

                            Text("Premium for 30% Off")
                                .font(.system(size: 32, weight: .bold))
                                .multilineTextAlignment(.center)

                            Text("For a limited time, get Day One Premium for just **$34.99** (normally $49.99) — your first year at **30% off**.")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 0)
                    }
                    .listRowBackground(Color.clear)
                    
                    Section {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.white)
                            Text("OFFER ENDS WEDNESDAY")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        .listRowInsets(EdgeInsets(top: 12, leading: 32, bottom: 12, trailing: 32))
                    }
                    .listRowBackground(Color.clear)

                    

                    Section {
                        Text("Enjoy everything Premium offers — including new features:")
                            .font(.system(size: 15, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .listRowBackground(Color.clear)

                    Section {
                        PremiumFeatureRow(
                            emoji: "🏃‍♂️",
                            title: "Strava Integration",
                            description: "Automatically journal your workouts"
                        )

                        PremiumFeatureRow(
                            emoji: "⚡️",
                            title: "Zapier Integration",
                            description: "Connect Day One to 6,000+ apps"
                        )

                        PremiumFeatureRow(
                            emoji: "🧪",
                            title: "Labs Early Access",
                            description: "Try upcoming experimental features first"
                        )
                    }
                    
                    // Spacer for button area
                    Section {
                        Color.clear
                            .frame(height: 50)
                    }
                    .listRowBackground(Color.clear)

                    
                }

                // Fixed button and footer at bottom
                VStack(spacing: 12) {
                    Button(action: {
                        // TODO: Handle upgrade action
                        dismiss()
                    }) {
                        Text("Upgrade Now")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "5B4FDB"), Color(hex: "44C0FF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Text("Thank you for being part of the Day One community.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "xmark") {
                        dismiss()
                    }
                    .labelStyle(.titleAndIcon)
                    .tint(Color(hex: "dddddd"))
                }
            }
        }
    }
}

// MARK: - Premium Feature Row
struct PremiumFeatureRow: View {
    let emoji: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))

                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PremiumOfferView()
}
