import SwiftUI

// MARK: - Shared Bio Data Model
@Observable
class BioData {
    var name = ""
    var birthdate = Date()
    var gender = ""
    var homeLocation = ""
    var maritalStatus = ""
    var job = ""
    var hobbies = ""
    var familyFriends = ""
    var includeInDailySurveys = false
    
    // Physical attributes
    var height = ""
    var weight = ""
    var skinColor = ""
    var hairColor = ""
    var hairType = ""
    var eyeColor = ""
    var bodyType = ""
    var ethnicity = ""
    
    static let shared = BioData()
    
    private init() {}
}

struct BioSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bioData = BioData.shared
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Profile header with photo
                VStack(spacing: 16) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: "camera.fill")
                                        .font(.title2)
                                        .foregroundStyle(.gray)
                                    Text("Add Photo")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("Personal Information")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Tell us about yourself to personalize your journaling experience")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Bio sections list
                List {
                    Section {
                        NavigationLink("Basics") {
                            BioBasicsView()
                        }
                        
                        NavigationLink("Physical Attributes") {
                            BioPhysicalAttributesView()
                        }
                    }
                    
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Include in Daily Surveys")
                                    .font(.body)
                                
                                Text("Add your bio context to survey questions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $bioData.includeInDailySurveys)
                                .labelsHidden()
                        }
                    }
                }
                .listStyle(.insetGrouped)
                
                Spacer()
            }
            .navigationTitle("Bio")
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

struct BioBasicsView: View {
    @State private var bioData = BioData.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Basic information form
                VStack(spacing: 0) {
                    BioFormRow(title: "Name", text: $bioData.name, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    HStack {
                        Text("Birthdate")
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        DatePicker("", selection: $bioData.birthdate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .padding()
                    .background(.white)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Gender", text: $bioData.gender, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Home Location", text: $bioData.homeLocation, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Marital Status", text: $bioData.maritalStatus, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Job", text: $bioData.job, isMultiLine: true)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Hobbies", text: $bioData.hobbies, isMultiLine: true)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Family & Friends", text: $bioData.familyFriends, isMultiLine: true)
                }
                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Basics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BioPhysicalAttributesView: View {
    @State private var bioData = BioData.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Instruction text
                VStack(alignment: .leading, spacing: 8) {
                    Text("Optional details to enhance your personal profile")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                .padding(.top, 8)
                
                // Physical attributes form
                VStack(spacing: 0) {
                    BioFormRow(title: "Height", text: $bioData.height, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Weight", text: $bioData.weight, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Body Type", text: $bioData.bodyType, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Ethnicity", text: $bioData.ethnicity, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Skin Color", text: $bioData.skinColor, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Hair Color", text: $bioData.hairColor, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Hair Type", text: $bioData.hairType, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Eye Color", text: $bioData.eyeColor, isMultiLine: false)
                }
                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Physical Attributes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BioFormRow: View {
    let title: String
    @Binding var text: String
    let isMultiLine: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title label
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Input field
            if isMultiLine {
                TextField("Enter \(title.lowercased())...", text: $text, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3, reservesSpace: true)
            } else {
                TextField("Enter \(title.lowercased())...", text: $text)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding()
        .background(.white)
    }
}

#Preview {
    BioSettingsView()
}