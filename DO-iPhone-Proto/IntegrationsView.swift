import SwiftUI

struct IntegrationsView: View {
    var body: some View {
        List {
            NavigationLink("Apple Health") {
                AppleHealthIntegrationView()
            }
            
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