import SwiftUI

struct FlashSaleView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 20) {
                        // Party popper icon
                        Image(systemName: "party.popper.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "5B4FDB"), Color(hex: "8B7FEB")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, 12)
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)

                Section {
                    VStack(spacing: 16) {
                        Text("For You: 40% Off Premium")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)

                        Text("For a limited time, receive 40% off your first year of Premium.")
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
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
                    .listRowInsets(EdgeInsets(top: 8, leading: 32, bottom: 8, trailing: 32))
                }
                .listRowBackground(Color.clear)

                Section {
                    Text("Thank you for being a Day One Premium member")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)

                Section {
                    Button(action: {
                        // TODO: Handle continue action
                        dismiss()
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "5B4FDB"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowInsets(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Flash Sale")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.gray.opacity(0.5))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
}

#Preview {
    FlashSaleView()
}
