import SwiftUI

extension TodayView {

    // MARK: - Moments Computed Properties
    func momentCount(for date: Date, type: String, maxCount: Int) -> Int {
        guard maxCount > 0 else { return 0 }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        // Create a consistent seed from the date and type (use smaller numbers to avoid overflow)
        let seed = ((components.year ?? 2024) % 100) * 10000 + (components.month ?? 1) * 100 + (components.day ?? 1)

        // Use a simpler hash to avoid overflow
        var hasher = Hasher()
        hasher.combine(seed)
        hasher.combine(type)
        let hashValue = abs(hasher.finalize())

        // Use seed to generate pseudo-random but consistent value
        let value = hashValue % 100

        // Different probability distributions based on value
        // ~20% chance of 0, ~50% chance of 1-2, ~30% chance of 3+
        if value < 20 {
            return 0  // No moments this day
        } else if value < 70 {
            // 1-2 items
            if maxCount == 1 {
                return 1
            } else {
                return 1 + (hashValue % 2)
            }
        } else {
            // 3 to maxCount items
            if maxCount <= 3 {
                return min(maxCount, 3)
            } else {
                let range = maxCount - 2
                return 3 + (hashValue % range)
            }
        }
    }

    var availablePhotosCount: Int {
        momentCount(for: selectedDate, type: "photos", maxCount: 12)
    }

    var dynamicPlacesCount: Int {
        momentCount(for: selectedDate, type: "places", maxCount: 6)
    }

    var dynamicEventsCount: Int {
        momentCount(for: selectedDate, type: "events", maxCount: 5)
    }

    var momentsCollapsedSummary: String {
        let totalSelected = selectedMomentsPhotos.count + selectedMomentsPlaces.count + selectedMomentsEvents.count
        if totalSelected == 0 {
            return "Select..."
        } else {
            return "\(totalSelected) Selected"
        }
    }

    var momentsButtonColor: Color {
        let totalSelected = selectedMomentsPhotos.count + selectedMomentsPlaces.count + selectedMomentsEvents.count
        return totalSelected == 0 ? Color(hex: "44C0FF") : Color(hex: "34C759")
    }

    var hasTrackersData: Bool {
        return !selectedMomentsTrackers.isEmpty
    }

    var trackerTimeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 12 ? "AM" : "PM"
    }

    // MARK: - Moments Section View-Builders
    // Moments Section - Photos
    @ViewBuilder
    var momentsPhotosSection: some View {
        Section {
            Button(action: {
                showingMomentsSelector = true
            }) {
                HStack(alignment: .center, spacing: 12) {
                    // Left icon - fixed width
                    Image(dayOneIcon: .photo)
                        .font(.system(size: 20))
                        .foregroundStyle(BrandColors.journalLavender)
                        .frame(width: 32)

                    if selectedMomentsPhotos.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Photos")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            Text("Select notable photos...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("Select from 12")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    } else {
                        // Show photo thumbnails horizontally in a scrollable container
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(Array(selectedMomentsPhotos).sorted(), id: \.self) { photoId in
                                    if let index = Int(photoId.replacingOccurrences(of: "photo_", with: "")) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(photoColors[index % photoColors.count])
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .frame(height: 44)

                        // Right side indicator - fixed
                        HStack(spacing: 4) {
                            Text("\(selectedMomentsPhotos.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    }
                }
                .frame(minHeight: 44)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: momentsSectionSpacing, leading: 16, bottom: momentsSectionSpacing, trailing: 16))
        .listRowBackground(showGuides ? Color.purple.opacity(0.2) : cellBackgroundColor)
    }

    // Moments Section - Places
    @ViewBuilder
    var momentsPlacesSection: some View {
        Section {
            Button(action: {
                showingMomentsSelector = true
            }) {
                HStack(spacing: 12) {
                    Image(dayOneIcon: .map_pin)
                        .font(.system(size: 20))
                        .foregroundStyle(BrandColors.journalAqua)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Places")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        if selectedMomentsPlaces.isEmpty {
                            Text("Select notable visits...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(Array(selectedMomentsPlaces).sorted().joined(separator: ", "))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                    }

                    Spacer()

                    if selectedMomentsPlaces.isEmpty {
                        Text("Select from \(placesData.count)")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    } else {
                        HStack(spacing: 4) {
                            Text("\(selectedMomentsPlaces.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: momentsSectionSpacing, leading: 16, bottom: momentsSectionSpacing, trailing: 16))
        .listRowBackground(showGuides ? Color.orange.opacity(0.2) : cellBackgroundColor)
    }

    // Moments Section - Events
    @ViewBuilder
    var momentsEventsSection: some View {
        Section {
            Button(action: {
                showingMomentsSelector = true
            }) {
                HStack(spacing: 12) {
                    Image(dayOneIcon: .calendar)
                        .font(.system(size: 20))
                        .foregroundStyle(BrandColors.journalFire)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Events")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        if selectedMomentsEvents.isEmpty {
                            Text("Select notable events...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(Array(selectedMomentsEvents).sorted().joined(separator: ", "))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                    }

                    Spacer()

                    if selectedMomentsEvents.isEmpty {
                        Text("Select from \(eventsData.count)")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    } else {
                        HStack(spacing: 4) {
                            Text("\(selectedMomentsEvents.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: momentsSectionSpacing, leading: 16, bottom: momentsSectionSpacing, trailing: 16))
        .listRowBackground(showGuides ? Color.pink.opacity(0.2) : cellBackgroundColor)
    }

    // Moments Section - Trackers
    @ViewBuilder
    var momentsTrackersSection: some View {
        Section {
            Button(action: {
                showingMomentsTrackersSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20))
                        .foregroundStyle(.orange)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trackers")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        if selectedMomentsTrackers.isEmpty {
                            Text("Track mood, energy, and stress...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(selectedMomentsTrackers.sorted(by: { $0.key < $1.key }).map { "\($0.key): \($0.value)" }.joined(separator: ", "))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                    }

                    Spacer()

                    if selectedMomentsTrackers.isEmpty {
                        let hour = Calendar.current.component(.hour, from: Date())
                        let timeOfDay = hour < 12 ? "AM" : "PM"
                        Text("Input \(timeOfDay)")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    } else {
                        HStack(spacing: 4) {
                            Text("\(selectedMomentsTrackers.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: momentsSectionSpacing, leading: 16, bottom: momentsSectionSpacing, trailing: 16))
        .listRowBackground(showGuides ? Color.cyan.opacity(0.2) : cellBackgroundColor)
    }

    // Moments Section - Inputs
    @ViewBuilder
    var momentsInputsSection: some View {
        Section {
            Button(action: {
                showingMomentsInputsSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 20))
                        .foregroundStyle(BrandColors.journalGreen)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Inputs")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        if hasInputsData {
                            Text(completedInputsList)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        } else {
                            Text("Add text inputs...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if hasInputsData {
                        HStack(spacing: 4) {
                            Text("\(completedInputsCount)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    } else {
                        Text("Log Daily Details")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: momentsSectionSpacing, leading: 16, bottom: momentsSectionSpacing, trailing: 16))
        .listRowBackground(showGuides ? Color.yellow.opacity(0.2) : cellBackgroundColor)
    }

    var hasInputsData: Bool {
        !foodInput.isEmpty || !dailyIntentionInput.isEmpty || !prioritiesInput.isEmpty || !mediaInput.isEmpty || !peopleInput.isEmpty
    }

    var completedInputsCount: Int {
        var count = 0
        if !foodInput.isEmpty { count += 1 }
        if !dailyIntentionInput.isEmpty { count += 1 }
        if !prioritiesInput.isEmpty { count += 1 }
        if !mediaInput.isEmpty { count += 1 }
        if !peopleInput.isEmpty { count += 1 }
        return count
    }

    var completedInputsList: String {
        var inputs: [String] = []
        if !foodInput.isEmpty { inputs.append(foodInput) }
        if !dailyIntentionInput.isEmpty { inputs.append(dailyIntentionInput) }
        if !prioritiesInput.isEmpty { inputs.append(prioritiesInput) }
        if !mediaInput.isEmpty { inputs.append(mediaInput) }
        if !peopleInput.isEmpty { inputs.append(peopleInput) }
        return inputs.joined(separator: ", ")
    }

    // MARK: - Collapsible Section Wrappers
    // Moments section - collapsible (Events, Places, Photos only)
    @ViewBuilder
    var momentsCollapsibleSection: some View {
        // Header
        Section {
            HStack(spacing: 12) {
                Text("Moments")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "292F33"))

                Spacer()

                // Collapsed state indicator
                if !momentsExpanded {
                    Button(action: { showingMomentsSelector = true }) {
                        Text(momentsCollapsedSummary)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(momentsButtonColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(momentsButtonColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Toggle arrow - always on the far right
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        momentsExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: todayToggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(momentsExpanded ? 90 : 0))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        // Content
        if momentsExpanded {
            Section {
                HStack(spacing: 4) {
                    MomentOption(
                        icon: .photo,
                        count: availablePhotosCount,
                        title: "Photos",
                        position: .left,
                        onTap: { showingMomentsSelector = true }
                    )

                    MomentOption(
                        icon: .map_pin_filled,
                        count: dynamicPlacesCount,
                        title: "Places",
                        position: .center,
                        onTap: { showingMomentsSelector = true }
                    )

                    MomentOption(
                        icon: .calendar,
                        count: dynamicEventsCount,
                        title: "Events",
                        position: .right,
                        onTap: { showingMomentsSelector = true }
                    )
                }
                //.padding(.vertical, 16)
            }
            //.listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    // Trackers section - collapsible
    @ViewBuilder
    var trackersCollapsibleSection: some View {
        // Header
        Section {
            HStack(spacing: 12) {
                Text("Trackers")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "292F33"))

                Spacer()

                // Collapsed state indicator
                if !trackersExpanded {
                    if hasTrackersData {
                        // Show count with checkmark
                        HStack(spacing: 4) {
                            Text("\(selectedMomentsTrackers.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "44C0FF").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        // Show "Input AM/PM" prompt
                        Button(action: { }) {  // No action - visual only
                            Text("Input \(trackerTimeOfDay)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(hex: "44C0FF"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "44C0FF").opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // Toggle arrow - always on the far right
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        trackersExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: todayToggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(trackersExpanded ? 90 : 0))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        // Content
        if trackersExpanded {
            momentsTrackersSection
        }
    }

    // Inputs section - collapsible
    @ViewBuilder
    var inputsCollapsibleSection: some View {
        // Header
        Section {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    inputsExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Inputs")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "292F33"))

                    Spacer()

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: todayToggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(inputsExpanded ? 90 : 0))
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(PlainButtonStyle())
            .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        // Content
        if inputsExpanded {
            momentsInputsSection
        }
    }
}
