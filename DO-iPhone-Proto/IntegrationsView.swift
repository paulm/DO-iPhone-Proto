import SwiftUI

struct IntegrationsView: View {
    var body: some View {
        List {
            NavigationLink("IFTTT") {
                Text("IFTTT Integration")
                    .navigationTitle("IFTTT")
                    .navigationBarTitleDisplayMode(.large)
            }
            
            NavigationLink("Strava") {
                StravaIntegrationView()
            }
            
            NavigationLink("Zapier") {
                ZapierIntegrationView()
            }
        }
        .navigationTitle("Integrations")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        IntegrationsView()
    }
}