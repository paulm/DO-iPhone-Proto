import SwiftUI

struct WorkExperienceView: View {
    @State private var bioData = BioData.shared
    @State private var showingAddWork = false
    
    var body: some View {
        List {
            if bioData.workExperiences.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        Text("No work experience added")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Add your professional experience to enhance your profile")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add Work Experience") {
                            showingAddWork = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(bioData.workExperiences) { work in
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(work.title)
                                .font(.headline)
                            
                            Text(work.companyName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text(work.employmentType)
                                Text("•")
                                Text(work.location)
                            }
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            
                            if !work.description.isEmpty {
                                Text(work.description)
                                    .font(.footnote)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    bioData.workExperiences.remove(atOffsets: indexSet)
                }
            }
        }
        .navigationTitle("Work Experience")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddWork = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddWork) {
            NavigationStack {
                AddWorkExperienceView()
            }
        }
    }
}

// MARK: - Add Work Experience View
struct AddWorkExperienceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workExperience = WorkExperience()
    @State private var bioData = BioData.shared
    
    let employmentTypes = ["Full-time", "Part-time", "Self-employed", "Freelance", "Contract", "Internship", "Apprenticeship", "Seasonal"]
    let locationTypes = ["On-site", "Hybrid", "Remote"]
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $workExperience.title)
                
                Picker("Employment type", selection: $workExperience.employmentType) {
                    ForEach(employmentTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
            } header: {
                Text("Position")
            }
            
            Section {
                TextField("Company name", text: $workExperience.companyName)
                TextField("Location", text: $workExperience.location)
                
                Picker("Location type", selection: $workExperience.locationType) {
                    ForEach(locationTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
            } header: {
                Text("Company")
            }
            
            Section {
                Toggle("I am currently working in this role", isOn: $workExperience.isCurrentRole)
                
                DatePicker("Start date", selection: $workExperience.startDate, displayedComponents: .date)
                
                if !workExperience.isCurrentRole {
                    DatePicker("End date", selection: $workExperience.endDate, displayedComponents: .date)
                }
            } header: {
                Text("Time Period")
            }
            
            Section {
                TextField("Description", text: $workExperience.description, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
            } header: {
                Text("Description")
            } footer: {
                Text("Describe your responsibilities, achievements, and skills used")
            }
        }
        .navigationTitle("Add Work Experience")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    bioData.workExperiences.append(workExperience)
                    dismiss()
                }
                .disabled(workExperience.title.isEmpty || workExperience.companyName.isEmpty)
            }
        }
    }
}

// MARK: - Education View
struct EducationView: View {
    @State private var bioData = BioData.shared
    @State private var showingAddEducation = false
    
    var body: some View {
        List {
            if bioData.educationItems.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        Text("No education added")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Add your educational background to complete your profile")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add Education") {
                            showingAddEducation = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(bioData.educationItems) { education in
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(education.school)
                                .font(.headline)
                            
                            if !education.degree.isEmpty {
                                Text(education.degree)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if !education.fieldOfStudy.isEmpty {
                                Text(education.fieldOfStudy)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            
                            HStack {
                                Text("\(education.startYear) - \(education.endYear)")
                                if education.graduated {
                                    Text("• Graduated")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            
                            if !education.description.isEmpty {
                                Text(education.description)
                                    .font(.footnote)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    bioData.educationItems.remove(atOffsets: indexSet)
                }
            }
        }
        .navigationTitle("Education")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddEducation = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddEducation) {
            NavigationStack {
                AddEducationView()
            }
        }
    }
}

// MARK: - Add Education View
struct AddEducationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var educationItem = EducationItem()
    @State private var bioData = BioData.shared
    
    let years = Array(1950...2030).reversed().map { String($0) }
    let attendanceTypes = ["College", "Graduate School", "High School"]
    
    var body: some View {
        Form {
            Section {
                TextField("School", text: $educationItem.school)
                    .placeholder(when: educationItem.school.isEmpty) {
                        Text("Add your university")
                            .foregroundColor(.gray.opacity(0.5))
                    }
            } header: {
                Text("Education")
            }
            
            Section {
                HStack {
                    Picker("Start", selection: $educationItem.startYear) {
                        Text("Year").tag("")
                        ForEach(years, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Text("to")
                        .foregroundStyle(.secondary)
                    
                    Picker("End", selection: $educationItem.endYear) {
                        Text("Year").tag("")
                        ForEach(years, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Toggle("Graduated", isOn: $educationItem.graduated)
            } header: {
                Text("Time Period")
            }
            
            Section {
                TextField("Description", text: $educationItem.description, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
            } header: {
                Text("Description")
            }
            
            Section {
                ForEach(0..<3, id: \.self) { index in
                    TextField("Concentration", text: $educationItem.concentrations[index])
                }
            } header: {
                Text("Concentrations")
            }
            
            Section {
                Picker("Attended for", selection: $educationItem.attendedFor) {
                    ForEach(attendanceTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Attended for")
            }
            
            if educationItem.attendedFor != "High School" {
                Section {
                    TextField("Degree", text: $educationItem.degree)
                    
                    if educationItem.attendedFor == "College" || educationItem.attendedFor == "Graduate School" {
                        TextField("Field of Study", text: $educationItem.fieldOfStudy)
                    }
                }
            }
        }
        .navigationTitle("Add Education")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    bioData.educationItems.append(educationItem)
                    dismiss()
                }
                .disabled(educationItem.school.isEmpty)
            }
        }
    }
}

