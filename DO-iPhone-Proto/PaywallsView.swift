import SwiftUI

struct PaywallsView: View {
    @State private var showingFlashSale = false
    @State private var showingOnboardingUpgrade = false

    var body: some View {
        List {
            Section {
                Button(action: {
                    showingFlashSale = true
                }) {
                    HStack {
                        Text("Flash Sale Basic")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Button(action: {
                    showingOnboardingUpgrade = true
                }) {
                    HStack {
                        Text("Onboarding Upgrade")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .navigationTitle("Paywalls")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFlashSale) {
            FlashSaleView()
        }
        .sheet(isPresented: $showingOnboardingUpgrade) {
            OnboardingUpgradeView()
        }
    }
}

#Preview {
    NavigationStack {
        PaywallsView()
    }
}
