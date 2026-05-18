import SwiftUI

// MARK: - Data Population Methods

extension TodayView {
    func populateNewUserData() {
        // Clear all existing data for a brand new user experience
        ChatSessionManager.shared.clearAllSessions()

        // Clear all daily content entries
        let calendar = Calendar.current
        let today = Date()

        // Clear data for the past 2 months to ensure clean state
        for dayOffset in -60...4 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                DailyContentManager.shared.setHasEntry(false, for: date)
                DailyContentManager.shared.setHasSummary(false, for: date)
                DailyContentManager.shared.setEntryMessageCount(0, for: date)
            }
        }

        // Reset current state
        chatCompleted = false
        entryCreated = false
        hasInteractedWithChat = false
        chatMessageCount = 0

        // Post notification to update UI
        NotificationCenter.default.post(name: .dataPopulationChanged, object: nil)
    }

    func populatePast2WeeksData() {
        // This recreates the current default behavior - past 2 weeks of data
        ChatSessionManager.shared.clearAllSessions()

        let calendar = Calendar.current
        let today = Date()

        // Clear all data first
        for dayOffset in -60...4 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                DailyContentManager.shared.setHasEntry(false, for: date)
                DailyContentManager.shared.setHasSummary(false, for: date)
                DailyContentManager.shared.setEntryMessageCount(0, for: date)
            }
        }

        // Populate past 2 weeks with various states
        let dayConfigs = [
            (1, true, true),    // Yesterday: chat + entry
            (2, true, false),   // 2 days ago: chat only
            (3, true, true),    // 3 days ago: chat + entry
            (4, false, false),  // 4 days ago: no activity
            (5, true, false),   // 5 days ago: chat only
            (6, true, true),    // 6 days ago: chat + entry
            (7, false, false),  // 7 days ago: no activity
            (8, true, true),    // 8 days ago: chat + entry
            (9, false, false),  // 9 days ago: no activity
            (10, true, false),  // 10 days ago: chat only
            (11, false, false), // 11 days ago: no activity
            (12, true, true),   // 12 days ago: chat + entry
            (13, false, false), // 13 days ago: no activity
            (14, true, false)   // 14 days ago: chat only
        ]

        for (daysAgo, hasChat, hasEntry) in dayConfigs {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                if hasChat {
                    // Add chat messages
                    let messages = [
                        DailyChatMessage(content: "How's your day?", isUser: false, isLogMode: false),
                        DailyChatMessage(content: generateSampleResponse(for: daysAgo), isUser: true, isLogMode: false)
                    ]
                    ChatSessionManager.shared.saveMessages(messages, for: date)

                    if hasEntry {
                        DailyContentManager.shared.setHasEntry(true, for: date)
                        DailyContentManager.shared.setEntryMessageCount(1, for: date)
                    }
                }
            }
        }

        // Update current date state if needed
        updateCurrentDateState()

        // Post notification to update UI
        NotificationCenter.default.post(name: .dataPopulationChanged, object: nil)
    }

    func populate2MonthsData() {
        // Populate 2 months of consecutive usage
        ChatSessionManager.shared.clearAllSessions()

        let calendar = Calendar.current
        let today = Date()

        // Clear all data first
        for dayOffset in -60...4 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                DailyContentManager.shared.setHasEntry(false, for: date)
                DailyContentManager.shared.setHasSummary(false, for: date)
                DailyContentManager.shared.setEntryMessageCount(0, for: date)
            }
        }

        // Populate 2 months (60 days) with realistic usage pattern
        for daysAgo in 1...60 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                // Create a realistic usage pattern:
                // - 80% chance of chat interaction
                // - 60% chance of entry creation if chat exists
                // - Skip some days for realism (10% skip rate)

                let skipDay = Int.random(in: 1...10) == 1

                if !skipDay {
                    let hasChat = Int.random(in: 1...10) <= 8 // 80% chance

                    if hasChat {
                        // Add chat messages with varying lengths
                        let messageCount = Int.random(in: 1...5)
                        var messages: [DailyChatMessage] = []

                        messages.append(DailyChatMessage(content: "How's your day?", isUser: false, isLogMode: false))
                        messages.append(DailyChatMessage(content: generateSampleResponse(for: daysAgo), isUser: true, isLogMode: false))

                        // Add additional messages for variety
                        for i in 1..<messageCount {
                            if i % 2 == 0 {
                                messages.append(DailyChatMessage(content: generateFollowUpQuestion(for: i), isUser: false, isLogMode: false))
                            } else {
                                messages.append(DailyChatMessage(content: generateFollowUpResponse(for: daysAgo, index: i), isUser: true, isLogMode: false))
                            }
                        }

                        ChatSessionManager.shared.saveMessages(messages, for: date)

                        // 60% chance of entry creation
                        let hasEntry = Int.random(in: 1...10) <= 6
                        if hasEntry {
                            DailyContentManager.shared.setHasEntry(true, for: date)
                            DailyContentManager.shared.setEntryMessageCount(messages.filter { $0.isUser }.count, for: date)
                        }
                    }
                }
            }
        }

        // Update current date state if needed
        updateCurrentDateState()

        // Post notification to update UI
        NotificationCenter.default.post(name: .dataPopulationChanged, object: nil)
    }

    func addPlacesData() {
        // Generate places based on dynamic count
        let placesCount = dynamicPlacesCount
        if placesCount > 0 {
            let allVisits = Visit.generateRandomVisits(for: selectedDate)
            placesData = Array(allVisits.prefix(placesCount))
        } else {
            placesData = []
        }
    }

    func addEventsData() {
        // Generate events based on dynamic count
        let eventsCount = dynamicEventsCount
        if eventsCount > 0 {
            let allEvents = [
                (name: "Morning Team Standup", icon: DayOneIcon.calendar, time: "9:00 AM - 9:30 AM", type: "Work"),
                (name: "Dentist Appointment", icon: DayOneIcon.calendar, time: "11:00 AM - 12:00 PM", type: "Health"),
                (name: "Lunch with Sarah", icon: DayOneIcon.calendar, time: "12:30 PM - 1:30 PM", type: "Personal"),
                (name: "Project Review Meeting", icon: DayOneIcon.calendar, time: "2:00 PM - 3:00 PM", type: "Work"),
                (name: "Yoga Class", icon: DayOneIcon.calendar, time: "5:30 PM - 6:30 PM", type: "Wellness")
            ]
            eventsData = Array(allEvents.prefix(eventsCount))
        } else {
            eventsData = []
        }
    }

    func updateMomentsDataForSelectedDate() {
        // Generate data for all dates based on dynamic counts
        let placesCount = dynamicPlacesCount
        let eventsCount = dynamicEventsCount

        // Generate places data - limit to the count
        if placesCount > 0 {
            let allVisits = Visit.generateRandomVisits(for: selectedDate)
            placesData = Array(allVisits.prefix(placesCount))
        } else {
            placesData = []
        }

        // Generate events data - limit to the count
        if eventsCount > 0 {
            let allEvents = [
                (name: "Morning Team Standup", icon: DayOneIcon.calendar, time: "9:00 AM - 9:30 AM", type: "Work"),
                (name: "Dentist Appointment", icon: DayOneIcon.calendar, time: "11:00 AM - 12:00 PM", type: "Health"),
                (name: "Lunch with Sarah", icon: DayOneIcon.calendar, time: "12:30 PM - 1:30 PM", type: "Personal"),
                (name: "Project Review Meeting", icon: DayOneIcon.calendar, time: "2:00 PM - 3:00 PM", type: "Work"),
                (name: "Yoga Class", icon: DayOneIcon.calendar, time: "5:30 PM - 6:30 PM", type: "Wellness")
            ]
            eventsData = Array(allEvents.prefix(eventsCount))
        } else {
            eventsData = []
        }
    }

    func generateSampleResponse(for daysAgo: Int) -> String {
        let responses = [
            "Had a great day today! Finished some important work and feeling accomplished.",
            "Today was productive. Got through my todo list and even had time for a walk.",
            "Relaxing day. Spent quality time with family and recharged.",
            "Busy but fulfilling day at work. Made progress on the big project.",
            "Good day overall. Made progress on my personal goals.",
            "Challenging day but learned a lot. Tomorrow will be better.",
            "Wonderful day! Everything went smoothly and feeling grateful.",
            "Quiet day of reflection and planning for the week ahead.",
            "Exciting day with new opportunities presenting themselves.",
            "Normal day, nothing too special but content with the progress.",
            "Great workout and healthy meals today. Feeling energized.",
            "Creative day, worked on personal projects and feeling inspired.",
            "Social day, caught up with friends over coffee.",
            "Focused day of deep work. Got a lot done.",
            "Mixed day with ups and downs, but ending on a positive note."
        ]
        return responses[min(daysAgo % responses.count, responses.count - 1)]
    }

    func generateFollowUpQuestion(for index: Int) -> String {
        let questions = [
            "What was the highlight of your day?",
            "How are you feeling about tomorrow?",
            "Did anything unexpected happen?",
            "What are you grateful for today?",
            "Any challenges you overcame?"
        ]
        return questions[index % questions.count]
    }

    func generateFollowUpResponse(for daysAgo: Int, index: Int) -> String {
        let responses = [
            "The highlight was definitely completing that presentation I've been working on.",
            "Looking forward to tomorrow! Have some exciting meetings planned.",
            "Actually yes, ran into an old friend at the coffee shop. It was nice catching up.",
            "Grateful for my health and the support of my family.",
            "Yes, finally figured out that bug that's been bothering me for days!"
        ]
        return responses[(daysAgo + index) % responses.count]
    }
}
