import SwiftUI

struct TitleSuggestionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTitle: String? = nil
    
    let suggestedTitles = [
        "A Perfect Day at Sundance",
        "Finding Peace in Mountain Solitude",
        "Reflections from Stewart Falls",
        "Morning Hike, Evening Stars",
        "Pottery, People, and Perspective"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select a title for your entry")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(suggestedTitles, id: \.self) { title in
                                Button(action: {
                                    selectedTitle = title
                                }) {
                                    HStack {
                                        Text(title)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if selectedTitle == title {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color(hex: "44C0FF"))
                                        }
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedTitle == title ? Color(hex: "44C0FF") : Color.clear, lineWidth: 2)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Use Title button
                        if selectedTitle != nil {
                            Button(action: {
                                // Apply selected title
                                dismiss()
                            }) {
                                Text("Use This Title")
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
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Title Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    TitleSuggestionsView()
}