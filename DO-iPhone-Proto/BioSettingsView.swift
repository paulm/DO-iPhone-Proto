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

#Preview {
    BioSettingsView()
}