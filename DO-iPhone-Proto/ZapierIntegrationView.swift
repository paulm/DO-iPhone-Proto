import SwiftUI

struct ZapierIntegrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isConnected = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if !isConnected {
                // Disconnected state with ScrollView
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Zapier logo
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(hex: "FF4A00"))
                            .frame(width: 88, height: 88)
                            .overlay(
                                Text("Z")
                                    .font(.system(size: 54, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                            .padding(.top, 20)

                        // Description
                        Text("Connect Zapier to automate your journaling with 6,000+ apps and never miss capturing important moments.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)

                        // Features list - white inset grouped card
                        VStack(spacing: 0) {
                            ZapierFeatureRow(
                                icon: "bolt.fill",
                                title: "Smart Automation",
                                description: "Automatically create entries from emails, tasks, fitness goals, and more."
                            )

                            ZapierFeatureRow(
                                icon: "arrow.triangle.branch",
                                title: "Multi-App Workflows",
                                description: "Connect multiple apps together to build powerful journaling automations."
                            )

                            ZapierFeatureRow(
                                icon: "sparkles",
                                title: "Trigger Options",
                                description: "Create entries based on schedules, events, or custom conditions."
                            )

                            ZapierFeatureRow(
                                icon: "paintbrush.fill",
                                title: "Data Enrichment",
                                description: "Automatically add weather, location, and metadata to your entries."
                            )

                            ZapierFeatureRow(
                                icon: "app.connected.to.app.below.fill",
                                title: "6,000+ Integrations",
                                description: "Connect with Gmail, Slack, Todoist, Instagram, and thousands more.",
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
                        withAnimation {
                            isConnected = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("CONNECT WITH")
                                .font(.system(size: 17, weight: .bold))
                            Text("ZAPIER")
                                .font(.system(size: 17, weight: .heavy))
                                .tracking(0.5)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(hex: "FF4A00"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(Color(.systemGroupedBackground))
            } else {
                // Connected state with Form
                Form {
                    Section {
                        VStack(spacing: 12) {
                            // Zapier logo
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(hex: "FF4A00"))
                                .frame(width: 88, height: 88)
                                .overlay(
                                    Text("Z")
                                        .font(.system(size: 54, weight: .bold))
                                        .foregroundStyle(.white)
                                )

                            // Description
                            Text("Automate your journaling with 6,000+ apps. Create entries from emails, tasks, fitness goals, and more.")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.clear)

                    Section {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(.secondary)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Paul Mayne")
                                    .font(.system(size: 17))

                                Text("ID: 892341, connected 7/12/25")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)

                        Button(role: .destructive) {
                            withAnimation {
                                isConnected = false
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Disconnect Zapier")
                                Spacer()
                            }
                        }
                    } header: {
                        Text("Account")
                    }

                    Section {
                        VStack(spacing: 8) {
                            Text("POWERED BY")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .tracking(1)

                            Text("ZAPIER")
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundStyle(.primary)
                                .tracking(2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                    .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle("Zapier")
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

// MARK: - Zapier Feature Row
struct ZapierFeatureRow: View {
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
        ZapierIntegrationView()
    }
}