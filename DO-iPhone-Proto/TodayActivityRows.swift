import SwiftUI

// MARK: - Activity Row Components

struct TodayActivityRowWithCheckbox: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with colored background
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    )

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                if isCompleted {
                    Image(dayOneIcon: .checkmark_circle_filled)
                        .foregroundStyle(.green)
                        .font(.title3)
                } else {
                    Image(dayOneIcon: .checkbox_empty)
                        .foregroundStyle(.secondary.opacity(0.5))
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Custom row component with chat resume functionality (V2 with hyperlinks)
struct TodayActivityRowWithChatResumeV2: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let showResume: Bool
    let showDefaultContent: Bool
    let action: () -> Void
    let resumeAction: () -> Void
    let beginChatAction: () -> Void
    let logHighlightsAction: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with colored background
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    )

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if showResume {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if showDefaultContent {
                        Text("Log details about your day")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer()

                if showResume {
                    HStack(spacing: 4) {
                        Text("Resume")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))

                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if isCompleted {
                    Image(dayOneIcon: .checkmark_circle_filled)
                        .foregroundStyle(.green)
                        .font(.title3)
                } else {
                    HStack(spacing: 4) {
                        Text("Start Chat")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))

                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Custom row component with chat resume functionality
struct TodayActivityRowWithChatResume: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let showResume: Bool
    let action: () -> Void
    let resumeAction: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with colored background
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    )

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if showResume {
                        HStack(spacing: 4) {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button(action: resumeAction) {
                                Text("Resume")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                            .buttonStyle(PlainButtonStyle())

                            Spacer()
                        }
                    } else {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer()

                if isCompleted {
                    Image(dayOneIcon: .checkmark_circle_filled)
                        .foregroundStyle(.green)
                        .font(.title3)
                } else {
                    Image(dayOneIcon: .checkbox_empty)
                        .foregroundStyle(.secondary.opacity(0.5))
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Custom row component with moments-specific subtitle formatting
struct TodayActivityRowWithMomentsSubtitle: View {
    let icon: String
    let iconColor: Color
    let title: String
    let selectedCount: Int
    let isCompleted: Bool
    let selectedDate: Date
    let action: () -> Void

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }

    private var dynamicTitle: String {
        return "\(dayOfWeek) Moments"
    }

    private var relativeDateText: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else {
            let components = calendar.dateComponents([.day, .weekOfYear, .month, .year], from: selectedDate, to: now)

            if let days = components.day, abs(days) < 7 {
                let dayText = abs(days) == 1 ? "Day" : "Days"
                return abs(days) == 2 ? "Two Days Ago" : "\(abs(days)) \(dayText) Ago"
            } else if let weeks = components.weekOfYear, abs(weeks) < 5 {
                let weekText = abs(weeks) == 1 ? "Week" : "Weeks"
                return abs(weeks) == 1 ? "A Week Ago" : "\(abs(weeks)) \(weekText) Ago"
            } else if let months = components.month, abs(months) < 12 {
                let monthText = abs(months) == 1 ? "Month" : "Months"
                return abs(months) == 1 ? "A Month Ago" : "\(abs(months)) \(monthText) Ago"
            } else if let years = components.year {
                let yearText = abs(years) == 1 ? "Year" : "Years"
                return abs(years) == 1 ? "A Year Ago" : "\(abs(years)) \(yearText) Ago"
            }
        }

        return dayOfWeek
    }

    private var subtitleText: Text {
        if selectedCount == 0 {
            return Text("Select media, places, and events from ")
                .foregroundStyle(.secondary) +
            Text(relativeDateText)
                .foregroundStyle(Color(hex: "44C0FF"))
        } else {
            return Text("\(selectedCount) selected. ")
                .foregroundStyle(.secondary) +
            Text("Select more")
                .foregroundStyle(Color(hex: "44C0FF"))
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                        .font(.system(size: 16, weight: .medium))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(dynamicTitle)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    subtitleText
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                Image(dayOneIcon: isCompleted ? .checkmark_circle_filled : .checkbox_empty)
                    .foregroundStyle(isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
