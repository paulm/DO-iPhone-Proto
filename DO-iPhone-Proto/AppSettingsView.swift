import SwiftUI

struct AppSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingChatSettings = false
    @State private var showingAIFeatures = false
    @AppStorage("aiFeaturesEnabled") private var aiFeaturesEnabled = false

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        // Avatar with star badge
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(.gray.opacity(0.3))

                            // Star badge
                            ZStack {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 24, height: 24)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white)
                            }
                            .offset(x: 4, y: -4)
                        }

                        Text("Paul Mayne")
                            .font(.title3)
                            .fontWeight(.medium)

                        Spacer()
                    }
                    .padding(.vertical, 8)

                    HStack {
                        Text("Account Status")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("Premium")
                            .foregroundStyle(Color(hex: "44C0FF"))
                    }

                    Text("Privacy, security, reliability — Day One was built from the ground up to safeguard your memories.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                }

                // Sync Section
                Section {
                    HStack {
                        Image(systemName: "cloud")
                            .frame(width: 24)
                            .foregroundStyle(.primary)
                        Text("Sync")
                        Spacer()
                        Text("On")
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .frame(width: 24)
                            .foregroundStyle(.primary)
                        Text("Last Sync")
                        Spacer()
                        Text("Jan 27, 2026 at 8:37 AM")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }

                // Main Settings Section
                Section {
                    SettingsRow(icon: "book", title: "Journals", trailingText: "22")
                    SettingsRow(icon: "questionmark.bubble", title: "Prompt Packs")

                    Button(action: {
                        showingAIFeatures = true
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                                .frame(width: 24)
                                .foregroundStyle(.primary)

                            Text("AI Features")
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(aiFeaturesEnabled ? "On" : "Off")
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    SettingsRow(icon: "message", title: "SMS to Journal")
                    SettingsRow(icon: "bell", title: "Reminders")
                    SettingsRow(icon: "questionmark.bubble", title: "Daily Prompts")
                    SettingsRow(icon: "doc.text", title: "Templates", trailingText: "4")
                    SettingsRow(icon: "calendar", title: "On This Day")
                }

                // Appearance Section
                Section {
                    SettingsRow(icon: "paintpalette", title: "Appearance", subtitle: "Lato System Font Size")
                    SettingsRow(icon: "lock", title: "Passcode")
                    SettingsRow(icon: "arrow.up.arrow.down.square", title: "Import / Export")
                    SettingsRow(icon: "book", title: "Book Printing")
                    SettingsRow(icon: "square.on.square", title: "App Icon")
                    SettingsRow(icon: "gearshape", title: "Advanced")
                }

                // Services Section
                Section {
                    SettingsRow(icon: "location", title: "Location History")
                    SettingsRow(icon: "envelope", title: "Email to Journal")
                    SettingsRow(icon: "heart", title: "Apple Health")
                    NavigationLink {
                        IntegrationsView()
                    } label: {
                        HStack {
                            Image(systemName: "bolt")
                                .frame(width: 24)
                                .foregroundStyle(.primary)
                            Text("Integrations")
                        }
                    }
                }

                // Support Section
                Section {
                    SettingsRow(icon: "lifepreserver", title: "Support")
                    NavigationLink {
                        LabsSettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "flask")
                                .frame(width: 24)
                                .foregroundStyle(.primary)
                            Text("Labs")
                        }
                    }
                    SettingsRow(icon: "number", title: "About")
                }

                // Developer Section
                Section {
                    SettingsRow(icon: "chevron.left.forwardslash.chevron.right", title: "Developer")
                }

                // Day One Logo Section
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "book.pages")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray.opacity(0.3))

                        Text("DAY ONE")
                            .font(.title2)
                            .fontWeight(.ultraLight)
                            .tracking(8)
                            .foregroundStyle(.gray.opacity(0.5))

                        Text("JOURNAL")
                            .font(.caption)
                            .fontWeight(.light)
                            .tracking(4)
                            .foregroundStyle(.gray.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                    .labelStyle(.titleAndIcon)
                    .tint(Color(hex: "44C0FF"))
                }
            }
            .sheet(isPresented: $showingChatSettings) {
                DailyChatSettingsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingAIFeatures) {
                AIFeaturesSettingsView()
            }
        }
    }
}

// Helper view for consistent row styling
struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var trailingText: String? = nil

    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundStyle(.primary)

                if let subtitle = subtitle {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .foregroundStyle(.primary)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(title)
                        .foregroundStyle(.primary)
                }

                Spacer()

                if let trailingText = trailingText {
                    Text(trailingText)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Feature List Item

struct FeatureListItem: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "44C0FF"))
                .padding(.top, 2)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - AI Features Settings View

struct AIFeaturesSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("aiFeaturesEnabled") private var aiFeaturesEnabled = false
    @AppStorage("dailyChatEnabled") private var dailyChatEnabled = false
    @AppStorage("entryAIFeaturesEnabled") private var entryAIFeaturesEnabled = false
    @State private var showingPrivacyAlert = false

    var body: some View {
        NavigationStack {
            List {
                // Primary AI Features Toggle
                Section {
                    HStack {
                        Text("AI Features")
                            .font(.body)

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { aiFeaturesEnabled },
                            set: { newValue in
                                if newValue {
                                    // Show privacy alert when enabling
                                    showingPrivacyAlert = true
                                } else {
                                    // Disable directly
                                    aiFeaturesEnabled = false
                                    dailyChatEnabled = false
                                    entryAIFeaturesEnabled = false
                                }
                            }
                        ))
                            .labelsHidden()
                            .tint(Color(hex: "44C0FF"))
                    }
                } footer: {
                    Text("Enable Day One AI features to enhance your journaling experience. [Learn more](https://dayoneapp.com/labs/ai-features/)")
                        .font(.footnote)
                }

                // Features Section - Informational
                Section {


                        VStack(alignment: .leading, spacing: 8) {
                            FeatureListItem(text: "Daily Chat - Natural conversations about your day")
                            FeatureListItem(text: "Entry Go-Deeper Prompts - Thoughtful follow-up questions")
                            FeatureListItem(text: "Entry Title Suggestions - AI-powered entry titles")
                            FeatureListItem(text: "Entry Highlights - Identify key moments")
                            FeatureListItem(text: "Entry Image Generation - Create beautiful AI images")
                        
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Day One AI Features")
                }

                // Apple Intelligence Section - Informational
                Section {

                        VStack(alignment: .leading, spacing: 8) {
                            FeatureListItem(text: "Go-Deeper Prompts")
                            FeatureListItem(text: "Title Suggestions")
                            FeatureListItem(text: "Entry Highlights")
                        
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Apple Intelligence")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("These features use Apple Intelligence to process everything directly on your device. No data is sent to servers.")
                            .font(.footnote)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("AI Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                    .labelStyle(.titleAndIcon)
                    .tint(Color(hex: "44C0FF"))
                }
            }
            .alert("AI Features Privacy", isPresented: $showingPrivacyAlert) {
                Button("Cancel", role: .cancel) { }
                Button("I Agree") {
                    aiFeaturesEnabled = true
                    dailyChatEnabled = true
                    entryAIFeaturesEnabled = true
                }
            } message: {
                Text("By enabling AI features, you consent to sharing content with our AI partner for processing.\n\n• Our AI partner does not store or train on your data\n• Used solely to generate content within Day One\n• You can disable AI features anytime\n\nThis ensures your privacy while providing AI-powered features to enhance your journaling experience.")
            }
        }
    }
}

#Preview {
    AppSettingsView()
}

#Preview("AI Features") {
    AIFeaturesSettingsView()
}
