import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingIntegrations = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Bio") {
                        BioSettingsView()
                    }
                }
                
                Section {
                    NavigationLink("Integrations") {
                        IntegrationsView()
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
        }
    }
}

#Preview {
    SettingsView()
}