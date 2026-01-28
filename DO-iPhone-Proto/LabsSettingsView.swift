import SwiftUI
import TipKit

enum LabsAvailability {
    case open
    case full
}

struct LabsSettingsView: View {
    @State private var showingLabsConfirmation = false
    @State private var dayOneLabsEnabled = false
    @State private var isEnablingFromConfirmation = false
    @State private var labsAvailability: LabsAvailability = .open
    @State private var aiFeatureAvailability: LabsAvailability = .open

    // Notification request states
    @State private var labsNotificationRequested = false
    @State private var aiFeatureNotificationRequested = false

    // Individual Labs feature toggles
    @AppStorage("aiFeaturesEnabled") private var aiFeaturesEnabled = false
    @State private var aiEntryChat = false
    @State private var aiSummaries = false
    @State private var showingAIFeaturesSettings = false

    // Labs Newsletter toggle
    @AppStorage("labsNewsletterEnabled") private var labsNewsletterEnabled = false

    // Helper function to disable all Labs features
    private func disableAllLabsFeatures() {
        aiFeaturesEnabled = false
        aiEntryChat = false
        aiSummaries = false
    }

    // Helper function to disable AI sub-features
    private func disableAISubFeatures() {
        aiEntryChat = false
        aiSummaries = false
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Share Feedback Section
                Section {
                    Button {
                        // TODO: Implement share feedback action
                    } label: {
                        HStack {
                            Text("Share Feedback")
                                .font(.body)
                                .foregroundStyle(Color(hex: "44C0FF"))

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    HStack {
                        Text("Labs Newsletter")
                            .font(.body)

                        Spacer()

                        Toggle("", isOn: $labsNewsletterEnabled)
                            .labelsHidden()
                            .tint(Color(hex: "44C0FF"))
                    }
                }
                
                // Header Section with Icon  
                Section {
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "44C0FF"))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "flask.fill")
                                    .font(.title)
                                    .foregroundStyle(.white)
                            )
                        
                        VStack(spacing: 8) {
                            Text("Day One Labs")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                            
                            Text("Get early access to experimental features and help shape the future of journaling. Explore new tools, share feedback, and preview what's next.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button("Learn More") {
                                // TODO: Implement learn more action
                            }
                            .font(.subheadline)
                            .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                
                // Labs Toggle Section
                Section {
                    HStack {
                        Text("Enable Labs")
                            .font(.body)
                        
                        Spacer()
                        
                        Toggle("", isOn: $dayOneLabsEnabled)
                            .labelsHidden()
                            .tint(Color(hex: "44C0FF"))
                            .disabled(labsAvailability == .full)
                            .onChange(of: dayOneLabsEnabled) { oldValue, newValue in
                                if newValue && !oldValue && !isEnablingFromConfirmation {
                                    showingLabsConfirmation = true
                                    dayOneLabsEnabled = false // Reset until confirmed
                                } else if !newValue {
                                    // Disable all sub-features when Labs is disabled
                                    disableAllLabsFeatures()
                                }
                                // Reset the flag after processing
                                if isEnablingFromConfirmation {
                                    isEnablingFromConfirmation = false
                                }
                            }
                    }
                    
                    // Warning row when Labs is full
                    if labsAvailability == .full {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.body)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Labs is currently full")
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Text("Get notified by email when we open up additional Labs slots.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                        // Notify Me row
                        Button {
                            labsNotificationRequested = true
                        } label: {
                            HStack {
                                if labsNotificationRequested {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                        Text("We'll notify you when Labs opens up")
                                            .foregroundStyle(.primary)
                                    }
                                } else {
                                    Text("Notify Me")
                                        .foregroundStyle(.blue)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                // AI Features Section (always show)
                Section {
                    Button(action: {
                        showingAIFeaturesSettings = true
                    }) {
                        HStack {
                            Text("AI Features")
                                .font(.body)
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(aiFeaturesEnabled ? "On" : "Off")
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    // Warning row when AI Features is full
                    if aiFeatureAvailability == .full {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.body)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Features is currently full")
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Text("Get notified by email when we open up additional AI Features slots.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                        // Notify Me row
                        Button {
                            aiFeatureNotificationRequested = true
                        } label: {
                            HStack {
                                if aiFeatureNotificationRequested {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                        Text("We'll notify you when AI Features opens up")
                                            .foregroundStyle(.primary)
                                    }
                                } else {
                                    Text("Notify Me")
                                        .foregroundStyle(.blue)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("AI Features")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("By enabling AI features, you consent to submitting certain content to our AI partner. Data is temporarily decrypted only when using AI features.")
                            .font(.footnote)
                        
                        Text("Our AI partner does not store or train on your data. It is solely used to generate content within Day One.")
                            .font(.footnote)
                        
                        Button("Learn More") {
                            // TODO: Implement learn more action
                        }
                        .font(.footnote)
                        .padding(.top, 4)
                    }
                }
                
                // Individual AI Feature Toggles (always show but dim when disabled)
                Section {
                    HStack {
                        Text("AI Entry Chat")
                            .font(.body)
                            .foregroundStyle(!dayOneLabsEnabled || !aiFeaturesEnabled || aiFeatureAvailability == .full ? .secondary : .primary)

                        Spacer()

                        Toggle("", isOn: $aiEntryChat)
                            .labelsHidden()
                            .tint(Color(hex: "44C0FF"))
                            .disabled(!dayOneLabsEnabled || !aiFeaturesEnabled || aiFeatureAvailability == .full)
                    }

                    HStack {
                        Text("AI Summaries")
                            .font(.body)
                            .foregroundStyle(!dayOneLabsEnabled || !aiFeaturesEnabled || aiFeatureAvailability == .full ? .secondary : .primary)

                        Spacer()

                        Toggle("", isOn: $aiSummaries)
                            .labelsHidden()
                            .tint(Color(hex: "44C0FF"))
                            .disabled(!dayOneLabsEnabled || !aiFeaturesEnabled || aiFeatureAvailability == .full)
                    }
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Individual AI features can be toggled on or off. Learn more about each feature in our documentation.")
                            .font(.footnote)

                        Button("Learn More") {
                            // TODO: Implement learn more action
                        }
                        .font(.footnote)
                        .padding(.top, 4)
                    }
                }
                
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section("Labs") {
                            Button {
                                labsAvailability = .open
                                labsNotificationRequested = false
                            } label: {
                                HStack {
                                    Text("Available")
                                    if labsAvailability == .open {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }

                            Button {
                                labsAvailability = .full
                            } label: {
                                HStack {
                                    Text("Full")
                                    if labsAvailability == .full {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }

                        Section("AI Features") {
                            Button {
                                aiFeatureAvailability = .open
                                aiFeatureNotificationRequested = false
                            } label: {
                                HStack {
                                    Text("Available")
                                    if aiFeatureAvailability == .open {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }

                            Button {
                                aiFeatureAvailability = .full
                            } label: {
                                HStack {
                                    Text("Full")
                                    if aiFeatureAvailability == .full {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }

                        Section("Debug") {
                            Button {
                                UserDefaults.standard.set(true, forKey: "ResetTipKitOnLaunch")
                            } label: {
                                Label("Reset All Tips (on relaunch)", systemImage: "arrow.counterclockwise")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showingLabsConfirmation) {
            LabsConfirmationView(
                isPresented: $showingLabsConfirmation,
                labsEnabled: $dayOneLabsEnabled,
                isEnablingFromConfirmation: $isEnablingFromConfirmation
            )
        }
        .sheet(isPresented: $showingAIFeaturesSettings) {
            AIFeaturesSettingsView()
        }
    }
}

struct LabsConfirmationView: View {
    @Binding var isPresented: Bool
    @Binding var labsEnabled: Bool
    @Binding var isEnablingFromConfirmation: Bool
    
    var body: some View {
        NavigationStack {
            List {
                // Privacy Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "lock.shield.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white)
                                )
                            
                            Text("Privacy & Security")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        
                        Text("Labs features are built with the same security and privacy standards Day One is known for. Your personal journal data remains protected.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 8)
                }
                
                // Labs Features Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.orange)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white)
                                )
                            
                            Text("Important Notice")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        
                        Text("Labs features are experimental and may change, be discontinued, or require a subscription. Your feedback helps us decide what becomes permanent.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 8)
                }
                
                // Enable Labs Section
                Section {
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.purple)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "flask.fill")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Labs")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                
                                Text("Access experimental features")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Button("Visit our FAQs") {
                                    // TODO: Open FAQ URL
                                }
                                .font(.footnote)
                                .padding(.top, 4)
                            }
                            
                            Spacer()
                        }
                        
                        Button("Enable Labs") {
                            isEnablingFromConfirmation = true
                            labsEnabled = true
                            isPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(Color(hex: "44C0FF"))
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Day One Labs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Labs Feature Toggle Component

struct LabsFeatureToggle: View {
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    var showLearnMore: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Toggle Row
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundStyle(isDisabled ? .secondary : .primary)
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .disabled(isDisabled)
            }
            .padding(.vertical, 4)
            
            // Description with divider
            VStack(alignment: .leading, spacing: 8) {
                Divider()
                
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if showLearnMore {
                    Button("Learn more") {
                        // TODO: Implement learn more action
                    }
                    .font(.footnote)
                    .padding(.top, 4)
                }
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - AI Feature Toggle Row Component

struct AIFeatureToggleRow: View {
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    var isDisabled: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(isDisabled ? .secondary : .primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button("Learn more") {
                        // TODO: Implement learn more action
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .disabled(isDisabled)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    LabsSettingsView()
}

#Preview("Confirmation") {
    LabsConfirmationView(isPresented: .constant(true), labsEnabled: .constant(false), isEnablingFromConfirmation: .constant(false))
}