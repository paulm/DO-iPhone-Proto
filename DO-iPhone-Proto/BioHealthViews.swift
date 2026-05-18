import SwiftUI

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

