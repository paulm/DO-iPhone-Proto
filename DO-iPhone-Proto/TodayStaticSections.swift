import SwiftUI

extension TodayView {

    // MARK: - Section Computed Properties
    var hasMomentsSelected: Bool {
        !selectedMomentsPlaces.isEmpty || !selectedMomentsEvents.isEmpty || !selectedMomentsPhotos.isEmpty
    }

    var dateRange: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        let today = Date()

        // Calculate how many dates we need based on screen width
        // Account for horizontal padding (16pt on each side)
        let approximateWidth = screenWidth - (DatePickerConstants.horizontalPadding * 2)
        let columnsPerRow = Int((approximateWidth + DatePickerConstants.spacing) / (DatePickerConstants.circleSize + DatePickerConstants.spacing))
        let totalDates = columnsPerRow * DatePickerConstants.numberOfRows

        // Calculate the starting date to ensure we end at least 2 days in the future (for Date Picker Row)
        let endDate = 2
        let startDate = endDate - totalDates + 1

        // Generate dates from calculated start to 2 days in the future
        for i in startDate...endDate {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }

        return dates
    }

    var trackersSummaryText: String {
        let completedCount = [
            moodRating > 0 ? 1 : 0,
            energyRating > 0 ? 1 : 0,
            stressRating > 0 ? 1 : 0,
            !foodInput.isEmpty ? 1 : 0,
            !prioritiesInput.isEmpty ? 1 : 0,
            !mediaInput.isEmpty ? 1 : 0,
            !peopleInput.isEmpty ? 1 : 0
        ].reduce(0, +)

        return "\(completedCount) of 7 completed"
    }

    var hasTrackerData: Bool {
        moodRating > 0 || energyRating > 0 || stressRating > 0 ||
        !foodInput.isEmpty || !prioritiesInput.isEmpty || !mediaInput.isEmpty || !peopleInput.isEmpty
    }

    // MARK: - Entry Links Section
    @ViewBuilder
    var entryLinksSection: some View {
        let entryCount = TodayDataManager.shared.getEntryCount(for: selectedDate)
        let onThisDayCount = TodayDataManager.shared.getOnThisDayCount(for: selectedDate)

        Group {
            if onThisDayCount > 0 {
                // Show both buttons side by side when there are On This Day entries
                HStack(spacing: 12) {
                    // Entries button
                    Button(action: {
                        if entryCount == 0 {
                            // Open Entry view to create new entry
                            showingEntry = true
                        } else {
                            // Open Entries list
                            showingEntries = true
                        }
                    }) {
                        HStack {
                            Text("\(entryCount) \(entryCount == 1 ? "Entry" : "Entries")")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: entryCount > 0 ? "chevron.right" : "plus")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(entryCount > 0 ? Color.secondary : Color(hex: "44C0FF"))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "F3F1F8"))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .buttonStyle(PlainButtonStyle())

                    // On This Day button
                    Button(action: {
                        showingOnThisDay = true
                    }) {
                        HStack {
                            Text("\(onThisDayCount) On This Day")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "F3F1F8"))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                // Show full-width Entries button when no On This Day entries
                Button(action: {
                    if entryCount == 0 {
                        // Open Entry view to create new entry
                        showingEntry = true
                    } else {
                        // Open Entries list
                        showingEntries = true
                    }
                }) {
                    HStack {
                        Text("\(entryCount) \(entryCount == 1 ? "Entry" : "Entries")")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: entryCount > 0 ? "chevron.right" : "plus")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(entryCount > 0 ? Color.secondary : Color(hex: "44C0FF"))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "F3F1F8"))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 0)
        .listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
        .listRowBackground(showGuides ? Color.blue.opacity(0.2) : Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - Date Navigation Section
    // Extract Date Navigation section as computed property
    @ViewBuilder
    var dateNavigationSection: some View {
        if showDateNavigation {
            Section {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDate = Date()
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Row 1: "Today" or relative date
                            Text(relativeDateText(for: selectedDate))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: "292F33")) // Day One Deep Blue
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Row 2: Full date - show weekday only for Today/Yesterday/Tomorrow
                            Text(formattedDateForNavigation(selectedDate))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    // Arrow navigation buttons
                    HStack(spacing: 12) {
                        // Previous day button
                        Button(action: {
                            if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedDate = previousDay
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(.systemGray2))
                                .frame(width: 48, height: 48)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Next day button
                        Button(action: {
                            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedDate = nextDay
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(.systemGray2))
                                .frame(width: 48, height: 48)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 0)
            }
            .listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
            .listRowBackground(showGuides ? Color.red.opacity(0.2) : cellBackgroundColor)
            .listRowSeparator(.hidden)
        }
    }

    // MARK: - Gold Upgrade Section
    @ViewBuilder
    var goldSection: some View {
        Section {
            HStack(spacing: 10) {
                Button(action: {
                    showGoldCelebration = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(hex: "F0B805"))

                        Text("Gold Upgraded")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "FAF0D7"))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    showSilverCelebration = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(hex: "B8C2C9"))

                        Text("Silver Upgraded")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "E8ECF0"))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // Extract Bio section as computed property
    @ViewBuilder
    var bioSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // Header content (title and subtitle outside the rounded rect)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bio")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "292F33"))
                    Text("Personal information and health data")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Bio button in rounded rectangle
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        showingBio = true
                    }) {
                        HStack {
                            Image(systemName: "person.text.rectangle")
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("View & Edit Bio")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.primary)

                                Text("Manage your personal profile")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(.systemGray3))
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
        }
        .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
