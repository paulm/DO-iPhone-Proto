import Foundation
import SwiftUI

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

// MARK: - Pet Model
struct Pet: Identifiable {
    let id = UUID()
    var name = ""
    var type = ""
    var gender = "Male" // "Male" or "Female"
    var color = ""
    var weight = ""
    var birthday = Date()
    var hasBirthday = false
    var deathDate = Date()
    var hasDeathDate = false
    var photoData: Data?
    var notes = ""

    // New structured sections
    var basicInformation: [String] = []
    var healthInformation: [String] = []
    var behaviorTraits: [String] = []
    var memoriesAndMilestones: [String] = []
    var importantDates: [String] = []
    var additionalNotes: [String] = []

    var age: String {
        guard hasBirthday else { return "Unknown age" }

        let endDate = hasDeathDate ? deathDate : Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: birthday, to: endDate)

        if let years = components.year, years > 0 {
            if years == 1 {
                return "1 year old"
            } else {
                return "\(years) years old"
            }
        } else if let months = components.month, months > 0 {
            if months == 1 {
                return "1 month old"
            } else {
                return "\(months) months old"
            }
        } else {
            return "< 1 month old"
        }
    }

    var isAlive: Bool {
        return !hasDeathDate
    }
}

// MARK: - Travel Model
struct Travel: Identifiable {
    let id = UUID()
    var destination = ""
    var country = ""
    var purpose = "Vacation" // Vacation, Business, Family Visit, Adventure, Other
    var startDate = Date()
    var endDate = Date()
    var companions = ""
    var accommodation = ""
    var highlights = ""
    var notes = ""
    var rating = 3 // 1-5 star rating
    var photoData: Data?
    var isFutureTrip = false
    
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        
        if start == end {
            return start
        } else {
            return "\(start) - \(end)"
        }
    }
    
    var isPast: Bool {
        return endDate < Date() && !isFutureTrip
    }
    
    var isOngoing: Bool {
        let now = Date()
        return startDate <= now && endDate >= now && !isFutureTrip
    }
    
    var duration: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let days = (components.day ?? 0) + 1
        
        if days == 1 {
            return "1 day"
        } else if days < 7 {
            return "\(days) days"
        } else if days == 7 {
            return "1 week"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks) week\(weeks > 1 ? "s" : "")"
        } else {
            let months = days / 30
            return "\(months) month\(months > 1 ? "s" : "")"
        }
    }
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
    
    // Pets
    var pets: [Pet] = [
        Pet(
            name: "Max",
            type: "Dog",
            gender: "Male",
            color: "Golden",
            weight: "65 lbs",
            birthday: Calendar.current.date(from: DateComponents(year: 2019, month: 3, day: 15)) ?? Date(),
            hasBirthday: true,
            deathDate: Date(),
            hasDeathDate: false,
            photoData: nil,
            notes: "Rescue dog from Golden Retriever Rescue. Very gentle with kids.",
            basicInformation: [
                "Breed: Golden Retriever",
                "Microchip: 985112007654321",
                "Adoption date: March 15, 2019"
            ],
            healthInformation: [
                "Last vet visit: Sep 15, 2025",
                "Vaccinations: Up to date (Rabies, DHPP)",
                "Allergies: None known",
                "Medication: Joint supplement daily"
            ],
            behaviorTraits: [
                "Loves swimming and playing fetch",
                "Gets along great with other dogs",
                "A bit afraid of thunderstorms"
            ],
            memoriesAndMilestones: [
                "March 15, 2019: Adoption day",
                "July 4, 2020: First camping trip",
                "Dec 25, 2022: Learned to ring bell for potty"
            ],
            importantDates: [
                "Annual checkup: Every March"
            ],
            additionalNotes: [
                "Favorite toy: Blue squeaky ball",
                "Grooming: Every 6 weeks at PetSmart"
            ]
        ),
        Pet(
            name: "Luna",
            type: "Cat",
            gender: "Female",
            color: "Calico",
            weight: "9 lbs",
            birthday: Calendar.current.date(from: DateComponents(year: 2021, month: 6, day: 1)) ?? Date(),
            hasBirthday: true,
            deathDate: Date(),
            hasDeathDate: false,
            photoData: nil,
            notes: "",
            basicInformation: [
                "Breed: Domestic Shorthair"
            ],
            healthInformation: [
                "Spayed: Yes",
                "Indoor cat only"
            ],
            behaviorTraits: [
                "Very independent",
                "Loves sitting in sunny spots",
                "Not a fan of being held"
            ],
            memoriesAndMilestones: [],
            importantDates: [
                "Adopted: June 1, 2021"
            ],
            additionalNotes: []
        ),
        Pet(
            name: "Charlie",
            type: "Parakeet",
            gender: "Male",
            color: "Blue and white",
            weight: "",
            birthday: Date(),
            hasBirthday: false,
            deathDate: Date(),
            hasDeathDate: false,
            photoData: nil,
            notes: "Loves to whistle and mimic sounds",
            basicInformation: [],
            healthInformation: [],
            behaviorTraits: [
                "Can whistle the first part of 'Happy Birthday'",
                "Chatty in the mornings"
            ],
            memoriesAndMilestones: [],
            importantDates: [],
            additionalNotes: [
                "Favorite treat: Millet spray"
            ]
        )
    ]
    
    // Travel
    var travels: [Travel] = []

    // Preferences & Tastes
    var favoriteBooks = ""
    var favoriteFilms = ""
    var favoriteTVShows = ""
    var favoriteMusic = ""
    var dietType = "" // Empty string for unselected state
    var foodDislikes = ""
    var foodAllergens = ""
    var favoriteFoods = ""
    var sportsTeams = ""
    var hobbiesInterests = ""
    var gear = ""

    // Hobbies
    var creativeHobbies = ""
    var outdoorActivities = ""
    var collections = ""
    var skillsLearning = ""

    // Digital Life & Online Presence
    var personalWebsite = ""
    var blog = ""
    var twitter = ""
    var instagram = ""
    var facebook = ""
    var linkedin = ""
    var github = ""
    var youtube = ""
    var tiktok = ""
    var mastodon = ""
    var threads = ""
    var otherSocialMedia = ""

    // Financial & Assets
    var investmentInterests = ""
    var majorPossessions = ""
    var financialGoals = ""
    var retirementPlanning = ""

    // Beliefs & Values
    var religiousSpiritualBeliefs = ""
    var politicalViews = ""
    var coreValues = ""
    var charitableCauses = ""
    var lifePhilosophy = ""

    static let shared = BioData()

    private init() {}
}
