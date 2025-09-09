import SwiftUI

// MARK: - Work Experience Model
struct WorkExperience: Identifiable {
    let id = UUID()
    var title = ""
    var employmentType = "Full-time"
    var companyName = ""
    var location = ""
    var locationType = "On-site"
    var isCurrentRole = false
    var startDate = Date()
    var endDate = Date()
    var description = ""
}

// MARK: - Education Model
struct EducationItem: Identifiable {
    let id = UUID()
    var school = ""
    var degree = ""
    var fieldOfStudy = ""
    var startYear = ""
    var endYear = ""
    var graduated = false
    var description = ""
    var concentrations: [String] = ["", "", ""]
    var attendedFor = "College" // College, Graduate School, High School
}

// MARK: - Place Lived Model
struct PlaceLived: Identifiable {
    let id = UUID()
    var placeName = ""
    var city = ""
    var movedInYear = ""
    var movedInMonth = ""
    var movedOutYear = ""
    var movedOutMonth = ""
    var stillLivingThere = false
}

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
    var physicalAppearanceNotes = ""
    
    // Health data
    var medicalConditions = ""
    var medications = ""
    var allergies = ""
    var fitnessGoals = ""
    var sleepHours = ""
    var activityLevel = ""
    
    // Enhanced Health Data
    // Vital Signs & Measurements
    var bloodPressure = ""
    var restingHeartRate = ""
    var bloodSugar = ""
    var cholesterol = ""
    var bmi = ""
    
    // Lifestyle & Habits
    var smokingStatus = ""
    var alcoholConsumption = ""
    var caffeineIntake = ""
    var stressLevel = ""
    var exerciseFrequency = ""
    var waterIntake = ""
    
    // Medical History
    var familyMedicalHistory = ""
    var previousSurgeries = ""
    var chronicConditions = ""
    var mentalHealthHistory = ""
    var recentIllnesses = ""
    
    // Wellness Indicators
    var energyLevel = ""
    var moodPatterns = ""
    var painLevels = ""
    var sleepQuality = ""
    var digestiveHealth = ""
    
    // Preventive Care
    var lastPhysicalExam = ""
    var vaccinationStatus = ""
    var screeningTests = ""
    var dentalHealth = ""
    
    // Women's Health (optional)
    var menstrualCycle = ""
    var pregnancyHistory = ""
    var menopauseStatus = ""
    
    // Mental Health
    var anxietyLevels = ""
    var depressionIndicators = ""
    var therapyCounseling = ""
    
    // Environmental Factors
    var workStress = ""
    var airQuality = ""
    var sunExposure = ""
    
    // Symptoms Tracking
    var headacheFrequency = ""
    var jointPain = ""
    var skinConditions = ""
    var visionHearing = ""
    var memoryCognitive = ""
    
    // Work Experience
    var workExperiences: [WorkExperience] = []
    
    // Education
    var educationItems: [EducationItem] = []
    
    // Places Lived
    var placesLived: [PlaceLived] = []
    
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
                        
                        NavigationLink("Work Experience") {
                            WorkExperienceView()
                        }
                        
                        NavigationLink("Education") {
                            EducationView()
                        }
                        
                        NavigationLink("Places Lived") {
                            PlacesLivedView()
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
                        
                        NavigationLink("People") {
                            PeopleView()
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
        Form {
            Section {
                TextField("Name", text: $bioData.name)
                DatePicker("Birthdate", selection: $bioData.birthdate, displayedComponents: .date)
                TextField("Gender", text: $bioData.gender)
                TextField("Home Location", text: $bioData.homeLocation)
                TextField("Marital Status", text: $bioData.maritalStatus)
            } header: {
                Text("Personal Information")
            }
            
            Section {
                TextField("Job", text: $bioData.job, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                
                TextField("Hobbies", text: $bioData.hobbies, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                
                TextField("Family & Friends", text: $bioData.familyFriends, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("About You")
            }
        }
        .navigationTitle("Basics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BioPhysicalAttributesView: View {
    @State private var bioData = BioData.shared
    
    var body: some View {
        Form {
            Section {
                TextField("Height", text: $bioData.height)
                TextField("Weight", text: $bioData.weight)
                TextField("Body Type", text: $bioData.bodyType)
                TextField("Ethnicity", text: $bioData.ethnicity)
            } header: {
                Text("Physical Measurements")
            } footer: {
                Text("Optional details to enhance your personal profile")
            }
            
            Section {
                TextField("Skin Color", text: $bioData.skinColor)
                TextField("Hair Color", text: $bioData.hairColor)
                TextField("Hair Type", text: $bioData.hairType)
                TextField("Eye Color", text: $bioData.eyeColor)
            } header: {
                Text("Appearance")
            }
            
            Section {
                TextField("Any other details related to your physical appearance", text: $bioData.physicalAppearanceNotes, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
            } header: {
                Text("Other Notes")
            }
        }
        .navigationTitle("Physical Attributes")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct BioHealthDataView: View {
    @State private var bioData = BioData.shared
    
    var body: some View {
        Form {
            Section {
                NavigationLink(destination: AppleHealthIntegrationView()) {
                    HStack(spacing: 12) {
                        // Apple Health Icon
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.red, Color.pink, Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Apple Health")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            
                            Text("Connect your health data")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            Section {
                TextField("Medical Conditions", text: $bioData.medicalConditions, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                
                TextField("Current Medications", text: $bioData.medications, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                
                TextField("Allergies", text: $bioData.allergies, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Medical Information")
            }
            
            Section {
                TextField("Fitness Goals", text: $bioData.fitnessGoals, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                
                TextField("Sleep Hours (typical)", text: $bioData.sleepHours)
                    .keyboardType(.numberPad)
                
                TextField("Activity Level", text: $bioData.activityLevel)
            } header: {
                Text("Lifestyle")
            }
        }
        .navigationTitle("Health Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BioEnhancedHealthDataView: View {
    @State private var bioData = BioData.shared
    
    var body: some View {
        Form {
            Section {
                TextField("Blood Pressure", text: $bioData.bloodPressure)
                TextField("Resting Heart Rate", text: $bioData.restingHeartRate)
                    .keyboardType(.numberPad)
                TextField("Blood Sugar", text: $bioData.bloodSugar)
                TextField("Cholesterol", text: $bioData.cholesterol)
                TextField("BMI", text: $bioData.bmi)
                    .keyboardType(.decimalPad)
            } header: {
                Text("Vital Signs & Measurements")
            } footer: {
                Text("Comprehensive health information helps AI provide personalized insights and recommendations")
            }
            
            Section {
                TextField("Smoking Status", text: $bioData.smokingStatus)
                TextField("Alcohol Consumption", text: $bioData.alcoholConsumption)
                TextField("Caffeine Intake", text: $bioData.caffeineIntake)
                TextField("Stress Level (1-10)", text: $bioData.stressLevel)
                    .keyboardType(.numberPad)
                TextField("Exercise Frequency", text: $bioData.exerciseFrequency)
                TextField("Water Intake", text: $bioData.waterIntake)
            } header: {
                Text("Lifestyle & Habits")
            }
            
            Section {
                TextField("Family Medical History", text: $bioData.familyMedicalHistory, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Previous Surgeries", text: $bioData.previousSurgeries, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Chronic Conditions", text: $bioData.chronicConditions, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Mental Health History", text: $bioData.mentalHealthHistory, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Recent Illnesses", text: $bioData.recentIllnesses, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Medical History")
            }
            
            Section {
                TextField("Energy Level (1-10)", text: $bioData.energyLevel)
                    .keyboardType(.numberPad)
                TextField("Mood Patterns", text: $bioData.moodPatterns, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Pain Levels (1-10)", text: $bioData.painLevels)
                    .keyboardType(.numberPad)
                TextField("Sleep Quality (1-10)", text: $bioData.sleepQuality)
                    .keyboardType(.numberPad)
                TextField("Digestive Health", text: $bioData.digestiveHealth, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Wellness Indicators")
            }
            
            Section {
                TextField("Last Physical Exam", text: $bioData.lastPhysicalExam)
                TextField("Vaccination Status", text: $bioData.vaccinationStatus, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Screening Tests", text: $bioData.screeningTests, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Dental Health", text: $bioData.dentalHealth, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Preventive Care")
            }
            
            Section {
                TextField("Menstrual Cycle", text: $bioData.menstrualCycle, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Pregnancy History", text: $bioData.pregnancyHistory, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Menopause Status", text: $bioData.menopauseStatus)
            } header: {
                Text("Women's Health")
            } footer: {
                Text("Optional section - fill out if applicable")
            }
            
            Section {
                TextField("Anxiety Levels (1-10)", text: $bioData.anxietyLevels)
                    .keyboardType(.numberPad)
                TextField("Depression Indicators", text: $bioData.depressionIndicators, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Therapy/Counseling", text: $bioData.therapyCounseling, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Mental Health")
            }
            
            Section {
                TextField("Work Stress (1-10)", text: $bioData.workStress)
                    .keyboardType(.numberPad)
                TextField("Air Quality", text: $bioData.airQuality)
                TextField("Sun Exposure", text: $bioData.sunExposure)
            } header: {
                Text("Environmental Factors")
            }
            
            Section {
                TextField("Headache Frequency", text: $bioData.headacheFrequency)
                TextField("Joint Pain/Stiffness", text: $bioData.jointPain, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Skin Conditions", text: $bioData.skinConditions, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Vision/Hearing Changes", text: $bioData.visionHearing, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
                TextField("Memory/Cognitive Concerns", text: $bioData.memoryCognitive, axis: .vertical)
                    .lineLimit(3, reservesSpace: false)
            } header: {
                Text("Symptoms Tracking")
            }
        }
        .navigationTitle("Enhanced Health Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Work Experience View
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

// MARK: - Places Lived View
struct PlacesLivedView: View {
    @State private var bioData = BioData.shared
    @State private var showingAddPlace = false
    @State private var editingPlace: PlaceLived?
    
    var body: some View {
        List {
            if bioData.placesLived.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        Text("No places added")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Add the places you've lived to tell your story")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add Place") {
                            showingAddPlace = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(bioData.placesLived) { place in
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if !place.placeName.isEmpty {
                                Text(place.placeName)
                                    .font(.headline)
                                Text(place.city)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(place.city)
                                    .font(.headline)
                            }
                            
                            if place.stillLivingThere {
                                if !place.movedInYear.isEmpty {
                                    Text("\(place.movedInMonth.isEmpty ? "" : place.movedInMonth + " ")\(place.movedInYear) - Present")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                } else {
                                    Text("Currently living here")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            } else {
                                let movedIn = "\(place.movedInMonth.isEmpty ? "" : place.movedInMonth + " ")\(place.movedInYear)"
                                let movedOut = "\(place.movedOutMonth.isEmpty ? "" : place.movedOutMonth + " ")\(place.movedOutYear)"
                                
                                if !place.movedInYear.isEmpty || !place.movedOutYear.isEmpty {
                                    Text("\(movedIn.isEmpty ? "?" : movedIn) - \(movedOut.isEmpty ? "?" : movedOut)")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button(action: {
                                editingPlace = place
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: {
                                if let index = bioData.placesLived.firstIndex(where: { $0.id == place.id }) {
                                    bioData.placesLived.remove(at: index)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Places Lived")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddPlace = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPlace) {
            NavigationStack {
                AddPlaceLivedView()
            }
        }
        .sheet(item: $editingPlace) { place in
            NavigationStack {
                AddPlaceLivedView(editingPlace: place)
            }
        }
    }
}

// MARK: - Add Place Lived View
struct AddPlaceLivedView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var place: PlaceLived
    @State private var bioData = BioData.shared
    
    let years = [""] + Array(1900...2030).reversed().map { String($0) }
    let months = ["", "January", "February", "March", "April", "May", "June", 
                  "July", "August", "September", "October", "November", "December"]
    
    var isEditing: Bool
    
    init(editingPlace: PlaceLived? = nil) {
        if let editingPlace = editingPlace {
            _place = State(initialValue: editingPlace)
            isEditing = true
        } else {
            _place = State(initialValue: PlaceLived())
            isEditing = false
        }
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Place Name", text: $place.placeName)
                TextField("City", text: $place.city)
            } header: {
                Text("Places lived")
            }
            
            Section {
                HStack {
                    Picker("Year", selection: $place.movedInYear) {
                        Text("Year").tag("")
                        ForEach(years.filter { !$0.isEmpty }, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Month", selection: $place.movedInMonth) {
                        Text("Month").tag("")
                        ForEach(months.filter { !$0.isEmpty }, id: \.self) { month in
                            Text(month).tag(month)
                        }
                    }
                    .pickerStyle(.menu)
                }
            } header: {
                Text("Moved In")
            }
            
            Section {
                Toggle("Still living there", isOn: $place.stillLivingThere)
                
                if !place.stillLivingThere {
                    HStack {
                        Picker("Year", selection: $place.movedOutYear) {
                            Text("Year").tag("")
                            ForEach(years.filter { !$0.isEmpty }, id: \.self) { year in
                                Text(year).tag(year)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Picker("Month", selection: $place.movedOutMonth) {
                            Text("Month").tag("")
                            ForEach(months.filter { !$0.isEmpty }, id: \.self) { month in
                                Text(month).tag(month)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            } header: {
                Text("Moved Out")
            }
        }
        .navigationTitle(isEditing ? "Edit Place" : "Add Place")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if isEditing {
                        // Update existing place
                        if let index = bioData.placesLived.firstIndex(where: { $0.id == place.id }) {
                            bioData.placesLived[index] = place
                        }
                    } else {
                        // Add new place
                        bioData.placesLived.append(place)
                    }
                    dismiss()
                }
                .disabled(place.city.isEmpty)
            }
        }
    }
}

// Helper extension for placeholder
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