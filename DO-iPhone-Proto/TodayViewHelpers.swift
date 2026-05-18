import SwiftUI

extension TodayView {

    // MARK: - Prompt Text

    var dailyEntryChatPromptText: String {
        let calendar = Calendar.current

        // Get day of week for the selected date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full day name (e.g., "Monday")
        let dayOfWeek = formatter.string(from: selectedDate)

        // Check special cases first
        if calendar.isDateInToday(selectedDate) {
            // For today, we could use time-based but keeping it simple
            return "How is your \(dayOfWeek)?"
        }

        if calendar.isDateInYesterday(selectedDate) {
            return "How was your \(dayOfWeek)?"
        }

        if calendar.isDateInTomorrow(selectedDate) {
            return "What's happening on \(dayOfWeek)?"
        }

        // For other dates, calculate the difference
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfSelectedDate = calendar.startOfDay(for: selectedDate)

        // This gives us the number of days between dates
        // Positive = future, Negative = past
        let daysDifference = calendar.dateComponents([.day], from: startOfToday, to: startOfSelectedDate).day ?? 0

        if daysDifference < 0 {
            // Past dates
            let daysAgo = abs(daysDifference)

            if daysAgo <= 7 {
                // Within past week
                return "How was your \(dayOfWeek)?"
            } else {
                // Older than a week
                return "How was this day?"
            }
        } else if daysDifference > 0 {
            // Future dates
            if daysDifference <= 7 {
                // Within next week
                return "What's happening on \(dayOfWeek)?"
            } else {
                // More than a week away
                return "What's happening on this \(dayOfWeek)?"
            }
        } else {
            // Fallback (shouldn't get here)
            return "Tell me about this day."
        }
    }

    // MARK: - Date / Navigation Helpers

    func relativeDateText(for date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            // For all other dates, show the day of the week
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Full weekday name (Monday, Tuesday, etc.)
            return formatter.string(from: date)
        }
    }

    func formattedDateForNavigation(_ date: Date) -> String {
        let calendar = Calendar.current

        // Check if it's Today, Yesterday, or Tomorrow
        if calendar.isDateInToday(date) ||
           calendar.isDateInYesterday(date) ||
           calendar.isDateInTomorrow(date) {
            // Show full format with weekday for these special days
            return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
        } else {
            // For all other dates, exclude the weekday but add relative time
            let baseDate = date.formatted(.dateTime.month(.abbreviated).day().year())
            let relativeTime = getRelativeTimeText(for: date)
            return "\(baseDate) (\(relativeTime))"
        }
    }

    func getRelativeTimeText(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0

        if days > 0 {
            // Past dates
            if days == 1 {
                return "1 day ago"
            } else if days < 7 {
                return "\(days) days ago"
            } else if days == 7 {
                return "1 week ago"
            } else if days < 14 {
                return "\(days) days ago"
            } else if days < 30 {
                let weeks = days / 7
                return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
            } else if days < 60 {
                return "1 month ago"
            } else if days < 365 {
                let months = days / 30
                return months == 1 ? "1 month ago" : "\(months) months ago"
            } else {
                let years = days / 365
                return years == 1 ? "1 year ago" : "\(years) years ago"
            }
        } else if days < 0 {
            // Future dates
            let futureDays = abs(days)
            if futureDays == 1 {
                return "in 1 day"
            } else if futureDays < 7 {
                return "in \(futureDays) days"
            } else if futureDays == 7 {
                return "in 1 week"
            } else if futureDays < 14 {
                return "in \(futureDays) days"
            } else if futureDays < 30 {
                let weeks = futureDays / 7
                return weeks == 1 ? "in 1 week" : "in \(weeks) weeks"
            } else if futureDays < 60 {
                return "in 1 month"
            } else if futureDays < 365 {
                let months = futureDays / 30
                return months == 1 ? "in 1 month" : "in \(months) months"
            } else {
                let years = futureDays / 365
                return years == 1 ? "in 1 year" : "in \(years) years"
            }
        } else {
            return "today"
        }
    }

    func navigateToPreviousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = newDate
            }
        }
    }

    func navigateToNextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = newDate
            }
        }
    }

    func generateEntry() {
        // Start generating entry
        isGeneratingEntry = true

        // After 1 second, mark entry as created and open it
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isGeneratingEntry = false
            // Mark entry as created
            DailyContentManager.shared.setHasEntry(true, for: selectedDate)
            // Track current message count when entry is created
            let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
            let userMessageCount = messages.filter { $0.isUser }.count
            DailyContentManager.shared.setEntryMessageCount(userMessageCount, for: selectedDate)
            // Update local state
            entryCreated = true
            // Post notification to update FAB
            NotificationCenter.default.post(name: .dailyEntryCreatedStatusChanged, object: selectedDate)
        }
    }

    // MARK: - Time Formatter

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    // MARK: - Section Order & State

    func loadSectionOrder() {
        let decoder = JSONDecoder()
        if let decodedSections = try? decoder.decode([SectionItem].self, from: sectionOrderData) {
            // Merge with allSections to add any new sections that don't exist yet
            var mergedSections = decodedSections

            // Find sections in allSections that aren't in decodedSections
            let existingIds = Set(decodedSections.map { $0.id })
            let newSections = SectionItem.allSections.filter { !existingIds.contains($0.id) }

            // Add new sections to the end
            mergedSections.append(contentsOf: newSections)

            sectionOrder = mergedSections

            // If we added new sections, save the updated order
            if !newSections.isEmpty {
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(mergedSections) {
                    sectionOrderData = encoded
                }
            }
        } else {
            sectionOrder = SectionItem.allSections
        }
    }

    func formatRelativeDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)

        if let days = components.day, days > 0 {
            if days == 1 {
                return "yesterday"
            } else {
                return "\(days) days ago"
            }
        } else if let hours = components.hour, hours > 0 {
            if hours == 1 {
                return "1 hour ago"
            } else {
                return "\(hours) hours ago"
            }
        } else if let minutes = components.minute, minutes > 0 {
            if minutes == 1 {
                return "1 minute ago"
            } else {
                return "\(minutes) minutes ago"
            }
        } else {
            return "just now"
        }
    }

    func updateCurrentDateState() {
        // Check if there are existing chat messages for the current date
        let existingMessages = ChatSessionManager.shared.getMessages(for: selectedDate)
        if !existingMessages.isEmpty {
            hasInteractedWithChat = true
            chatCompleted = true
            chatMessageCount = existingMessages.filter { $0.isUser }.count
        }

        // Check if entry exists for current date
        entryCreated = DailyContentManager.shared.hasEntry(for: selectedDate)
        summaryGenerated = DailyContentManager.shared.hasSummary(for: selectedDate)
    }
}
