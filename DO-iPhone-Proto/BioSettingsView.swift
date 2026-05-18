import SwiftUI

// MARK: - Work Experience Model

struct BioSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bioData = BioData.shared
    @State private var showingImagePicker = false
    @State private var showingBioChat = false

    var body: some View {
        NavigationStack {
            List {
                // Bio Chat section
                Section {
                    Button(action: {
                        showingBioChat = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color(hex: "44C0FF"))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Bio Chat")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text("Chat to enhance and complete your Bio details")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listRowBackground(Color(.systemGray6))

                // Bio sections
                Section {
                    NavigationLink("People") {
                        PeopleView()
                    }

                    NavigationLink("Pets") {
                        PetsView()
                    }

                    NavigationLink("Places Lived") {
                        PlacesLivedView()
                    }

                    NavigationLink("Work Experience") {
                        WorkExperienceView()
                    }

                    NavigationLink("Education") {
                        EducationView()
                    }

                    NavigationLink("Travel") {
                        TravelView()
                    }

                    NavigationLink("Physical Attributes") {
                        BioPhysicalAttributesView()
                    }

                    NavigationLink("Health Data") {
                        BioHealthDataView()
                    }

                    NavigationLink("Enhanced Health Data") {
                        BioEnhancedHealthDataView()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Extensive Bio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerPlaceholder()
            }
            .sheet(isPresented: $showingBioChat) {
                BioChatPlaceholder()
            }
        }
    }
}

// Placeholder for Bio Chat functionality
struct BioChatPlaceholder: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color(hex: "44C0FF"))

                Text("Bio Chat")
                    .font(.title2)
                    .fontWeight(.medium)

                Text("Chat with AI to enhance and complete your Bio details. This feature will help you add comprehensive information to your profile.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Start Chat") {
                    // Bio Chat functionality would go here
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "44C0FF"))
                .padding(.top, 20)
            }
            .padding()
            .navigationTitle("Bio Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Placeholder for image picker functionality
struct ImagePickerPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
                
                Text("Photo Selection")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Image picker functionality would be implemented here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button("Take Photo") {
                        // Camera functionality would go here
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Choose from Library") {
                        // Photo library functionality would go here
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 20)
            }
            .padding()
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    BioSettingsView()
}
