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
                        
                        NavigationLink("Health Data") {
                            BioHealthDataView()
                        }
                        
                        NavigationLink("Enhanced Health Data") {
                            BioEnhancedHealthDataView()
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

struct BioHealthDataView: View {
    @State private var bioData = BioData.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Apple Health Integration Section
                VStack(spacing: 0) {
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
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.white)
                    }
                    .buttonStyle(.plain)
                }
                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Health Information Form
                VStack(spacing: 0) {
                    BioFormRow(title: "Medical Conditions", text: $bioData.medicalConditions, isMultiLine: true)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Current Medications", text: $bioData.medications, isMultiLine: true)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Allergies", text: $bioData.allergies, isMultiLine: true)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Fitness Goals", text: $bioData.fitnessGoals, isMultiLine: true)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Sleep Hours (typical)", text: $bioData.sleepHours, isMultiLine: false)
                    
                    Divider().padding(.leading, 16)
                    
                    BioFormRow(title: "Activity Level", text: $bioData.activityLevel, isMultiLine: false)
                }
                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Health Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BioEnhancedHealthDataView: View {
    @State private var bioData = BioData.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Introduction
                VStack(alignment: .leading, spacing: 8) {
                    Text("Comprehensive health information helps AI provide personalized insights and recommendations")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                .padding(.top, 8)
                
                // Vital Signs & Measurements
                VStack(alignment: .leading, spacing: 12) {
                    Text("Vital Signs & Measurements")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        BioFormRow(title: "Blood Pressure", text: $bioData.bloodPressure, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Resting Heart Rate", text: $bioData.restingHeartRate, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Blood Sugar", text: $bioData.bloodSugar, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Cholesterol", text: $bioData.cholesterol, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "BMI", text: $bioData.bmi, isMultiLine: false)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Lifestyle & Habits
                VStack(alignment: .leading, spacing: 12) {
                    Text("Lifestyle & Habits")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        BioFormRow(title: "Smoking Status", text: $bioData.smokingStatus, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Alcohol Consumption", text: $bioData.alcoholConsumption, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Caffeine Intake", text: $bioData.caffeineIntake, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Stress Level (1-10)", text: $bioData.stressLevel, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Exercise Frequency", text: $bioData.exerciseFrequency, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Water Intake", text: $bioData.waterIntake, isMultiLine: false)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Medical History
                VStack(alignment: .leading, spacing: 12) {
                    Text("Medical History")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        BioFormRow(title: "Family Medical History", text: $bioData.familyMedicalHistory, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Previous Surgeries", text: $bioData.previousSurgeries, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Chronic Conditions", text: $bioData.chronicConditions, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Mental Health History", text: $bioData.mentalHealthHistory, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Recent Illnesses", text: $bioData.recentIllnesses, isMultiLine: true)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Wellness Indicators
                VStack(alignment: .leading, spacing: 12) {
                    Text("Wellness Indicators")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        BioFormRow(title: "Energy Level (1-10)", text: $bioData.energyLevel, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Mood Patterns", text: $bioData.moodPatterns, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Pain Levels (1-10)", text: $bioData.painLevels, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Sleep Quality (1-10)", text: $bioData.sleepQuality, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Digestive Health", text: $bioData.digestiveHealth, isMultiLine: true)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Preventive Care
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preventive Care")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        BioFormRow(title: "Last Physical Exam", text: $bioData.lastPhysicalExam, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Vaccination Status", text: $bioData.vaccinationStatus, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Screening Tests", text: $bioData.screeningTests, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Dental Health", text: $bioData.dentalHealth, isMultiLine: true)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Women's Health
                VStack(alignment: .leading, spacing: 12) {
                    Text("Women's Health")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        BioFormRow(title: "Menstrual Cycle", text: $bioData.menstrualCycle, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Pregnancy History", text: $bioData.pregnancyHistory, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Menopause Status", text: $bioData.menopauseStatus, isMultiLine: false)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Mental Health
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mental Health")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        BioFormRow(title: "Anxiety Levels (1-10)", text: $bioData.anxietyLevels, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Depression Indicators", text: $bioData.depressionIndicators, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Therapy/Counseling", text: $bioData.therapyCounseling, isMultiLine: true)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Environmental Factors
                VStack(alignment: .leading, spacing: 12) {
                    Text("Environmental Factors")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        BioFormRow(title: "Work Stress (1-10)", text: $bioData.workStress, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Air Quality", text: $bioData.airQuality, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Sun Exposure", text: $bioData.sunExposure, isMultiLine: false)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Symptoms Tracking
                VStack(alignment: .leading, spacing: 12) {
                    Text("Symptoms Tracking")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        BioFormRow(title: "Headache Frequency", text: $bioData.headacheFrequency, isMultiLine: false)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Joint Pain/Stiffness", text: $bioData.jointPain, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Skin Conditions", text: $bioData.skinConditions, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Vision/Hearing Changes", text: $bioData.visionHearing, isMultiLine: true)
                        Divider().padding(.leading, 16)
                        BioFormRow(title: "Memory/Cognitive Concerns", text: $bioData.memoryCognitive, isMultiLine: true)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Enhanced Health Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    BioSettingsView()
}