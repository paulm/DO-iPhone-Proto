import SwiftUI

struct ImageSuggestionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    let imageSuggestions = [
        (icon: "mountain.2.fill", title: "Mountain trail views", description: "Capture the scenic vistas from your hike"),
        (icon: "drop.fill", title: "Stewart Falls waterfall", description: "The cascading water and morning mist"),
        (icon: "sunrise.fill", title: "Sunrise through the aspens", description: "Golden hour lighting through the trees"),
        (icon: "cup.and.saucer.fill", title: "Morning coffee at the resort", description: "Your peaceful morning ritual"),
        (icon: "leaf.fill", title: "Fall foliage", description: "The changing colors of autumn leaves")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Consider adding these photos to your entry")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(imageSuggestions, id: \.title) { suggestion in
                                HStack(spacing: 16) {
                                    Image(systemName: suggestion.icon)
                                        .font(.title2)
                                        .foregroundStyle(Color(hex: "44C0FF"))
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(suggestion.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                        
                                        Text(suggestion.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(16)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Add Photos button
                        Button(action: {
                            // Open photo picker
                            dismiss()
                        }) {
                            Label("Add Photos", systemImage: "photo.badge.plus")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Image Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ImageSuggestionsView()
}