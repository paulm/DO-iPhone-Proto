import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingIntegrations = false
    @State private var showingChatSettings = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Bio") {
                        BioSettingsView()
                    }
                }
                
                Section {
                    Button(action: {
                        // Dismiss keyboard before showing settings
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        showingChatSettings = true
                    }) {
                        HStack {
                            Text("Daily Chat")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                
                Section {
                    NavigationLink("Integrations") {
                        IntegrationsView()
                    }
                }

                Section {
                    NavigationLink("Paywalls") {
                        PaywallsView()
                    }
                }

                Section {
                    NavigationLink("Labs") {
                        LabsSettingsView()
                    }
                }
                
                Section {
                    NavigationLink("Experiments") {
                        ExperimentsView()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingChatSettings) {
                DailyChatSettingsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    SettingsView()
}