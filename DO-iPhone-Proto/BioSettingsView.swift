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
    
    static let shared = BioData()
    
    private init() {}
}

struct BioSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bioData = BioData.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundStyle(.gray)
                            )
                        
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
                    
                    // Bio form
                    VStack(spacing: 0) {
                        BioFormRow(title: "Name", text: $bioData.name)
                        
                        Divider().padding(.leading, 16)
                        
                        HStack {
                            Text("Birthdate")
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            DatePicker("", selection: $bioData.birthdate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        .padding()
                        .background(.white)
                        
                        Divider().padding(.leading, 16)
                        
                        BioFormRow(title: "Gender", text: $bioData.gender)
                        
                        Divider().padding(.leading, 16)
                        
                        BioFormRow(title: "Home Location", text: $bioData.homeLocation)
                        
                        Divider().padding(.leading, 16)
                        
                        BioFormRow(title: "Marital Status", text: $bioData.maritalStatus)
                        
                        Divider().padding(.leading, 16)
                        
                        BioFormRow(title: "Job", text: $bioData.job)
                        
                        Divider().padding(.leading, 16)
                        
                        BioFormRow(title: "Hobbies", text: $bioData.hobbies)
                        
                        Divider().padding(.leading, 16)
                        
                        BioFormRow(title: "Family & Friends", text: $bioData.familyFriends)
                        
                        Divider().padding(.leading, 16)
                        
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
                        .padding()
                        .background(.white)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
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
        }
    }
}

struct BioFormRow: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter \(title.lowercased())...", text: $text)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.white)
    }
}

#Preview {
    BioSettingsView()
}