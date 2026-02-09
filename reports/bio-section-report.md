# Bio Section Report

## Overview
The Bio section is an optional, collapsible section in the Today tab that provides access to "Extensive Bio" - a comprehensive personal information management system. It's titled "Bio" with the subtitle "Personal information and health data" and can be shown/hidden via the Settings menu.

## Main Categories (9 total)

### 1. **People**
Organized into 6 predefined categories:
- **Family** - Parents, siblings, children, and extended family
- **Friends** - Close friends and social connections
- **Work** - Colleagues, managers, and professional contacts
- **Health** - Doctors, therapists, and health professionals
- **Community** - Neighbors, community members, and acquaintances
- **Services** - Service providers and business contacts

**Details per person:**
- Basic Information: Name, relationship, age, education, living situation
- Contact: Phone number, email
- Relationships: Connections to other people
- Key Details: Important facts
- Interactions: Logged interactions with dates
- Additional Notes: Free-form notes
- Metadata: Favorite flag, last interaction date, birthday

### 2. **Pets**
**Details per pet:**
- Basic Information: Name, type/breed, gender, color, weight, microchip, adoption date
- Health Information: Last vet visit, vaccinations, allergies, medications
- Behavior Traits: Personality, habits, fears
- Memories & Milestones: Important dates and achievements
- Important Dates: Recurring events (checkups, grooming)
- Additional Notes: Favorite toys, grooming schedule, etc.
- Dates: Birthday (optional), death date (optional)
- Photo support

### 3. **Places Lived**
**Details per location:**
- Place name
- City
- Move-in year and month
- Move-out year and month
- "Still living there" toggle

### 4. **Work Experience**
**Details per job:**
- Position: Title, employment type (Full-time, Part-time, Self-employed, Freelance, Contract, Internship, Apprenticeship, Seasonal)
- Company: Company name, location, location type (On-site, Hybrid, Remote)
- Time Period: Start date, end date, "Currently working" toggle
- Description: Free-form text

### 5. **Education**
**Details per education entry:**
- School name
- Degree
- Field of study
- Start year, end year
- Graduated toggle
- Description
- Concentrations (up to 3)
- Attended for: College, Graduate School, or High School

### 6. **Travel**
**Details per trip:**
- Destination and country
- Purpose: Vacation, Business, Family Visit, Adventure, Other
- Start and end dates
- Companions
- Accommodation
- Highlights
- Notes
- Rating (1-5 stars)
- Photo support
- "Future trip" toggle

### 7. **Physical Attributes**
**Physical Measurements:**
- Height
- Weight
- Body type
- Ethnicity

**Appearance:**
- Skin color
- Hair color
- Hair type
- Eye color

**Other Notes:**
- Free-form text for additional physical appearance details

### 8. **Health Data**
**Apple Health Integration:**
- Link to connect Apple Health data

**Medical Information:**
- Medical conditions
- Current medications
- Allergies

**Lifestyle:**
- Fitness goals
- Sleep hours (typical)
- Activity level

### 9. **Enhanced Health Data**

**Vital Signs & Measurements:**
- Blood pressure
- Resting heart rate
- Blood sugar
- Cholesterol
- BMI

**Lifestyle & Habits:**
- Smoking status
- Alcohol consumption
- Caffeine intake
- Stress level (1-10)
- Exercise frequency
- Water intake

**Medical History:**
- Family medical history
- Previous surgeries
- Chronic conditions
- Mental health history
- Recent illnesses

**Wellness Indicators:**
- Energy level (1-10)
- Mood patterns
- Pain levels (1-10)
- Sleep quality (1-10)
- Digestive health

**Preventive Care:**
- Last physical exam
- Vaccination status
- Screening tests
- Dental health

**Women's Health (optional):**
- Menstrual cycle
- Pregnancy history
- Menopause status

**Mental Health:**
- Anxiety levels (1-10)
- Depression indicators
- Therapy/counseling

**Environmental Factors:**
- Work stress (1-10)
- Air quality
- Sun exposure

**Symptoms Tracking:**
- Headache frequency
- Joint pain/stiffness
- Skin conditions
- Vision/hearing changes
- Memory/cognitive concerns

## Special Features

**Bio Chat (Placeholder):**
- AI-powered chat interface to enhance and complete Bio details
- Currently shows as a prominent button at the top of the Bio settings
- Implementation pending

**Daily Chat Integration:**
- Bio data can be optionally included in Daily Entry Chat context via toggle (`includeBio`)

**Sample Data:**
- Includes pre-populated sample data for demonstration:
  - 3 pets (Max the dog, Luna the cat, Charlie the parakeet)
  - Multiple people across categories
  - Structured with comprehensive details

## Architecture Notes
- All data stored in `BioData.shared` singleton using `@Observable` macro
- Bio section visibility controlled by `@AppStorage("showBioSection")` (default: false)
- Accessed from Today tab toolbar ellipsis menu → "Edit Bio"
- Full-screen sheet presentation with "Extensive Bio" title
