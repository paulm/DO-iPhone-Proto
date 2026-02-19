import SwiftUI

// MARK: - Section Item
struct SectionItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String

    static let allSections: [SectionItem] = [
        SectionItem(id: "dateNavigation", name: "Date Navigation"),
        SectionItem(id: "datePickerGrid", name: "Date Picker Grid"),
        SectionItem(id: "datePickerRow", name: "Date Picker Row"),
        SectionItem(id: "entries", name: "Entries"),
        SectionItem(id: "dailyEntry", name: "Daily Entry"),
        SectionItem(id: "dailyChat", name: "Daily Chat"),
        SectionItem(id: "bio", name: "Bio"),
        SectionItem(id: "moments", name: "Moments"),
        SectionItem(id: "trackers", name: "Trackers"),
        SectionItem(id: "inputs", name: "Inputs"),
        SectionItem(id: "gold", name: "Gold")
    ]
}

// MARK: - Today Sections Order View
struct TodaySectionsOrderView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("sectionOrder") private var sectionOrderData: Data = {
        let encoder = JSONEncoder()
        return (try? encoder.encode(SectionItem.allSections)) ?? Data()
    }()

    // Section visibility toggles
    @AppStorage("showDatePickerGrid") private var showDatePickerGrid = false
    @AppStorage("showDatePickerRow") private var showDatePickerRow = true
    @AppStorage("showDateNavigation") private var showDateNavigation = true
    @AppStorage("showEntries") private var showEntries = true
    @AppStorage("showDailyEntry") private var showDailyEntry = true
    @AppStorage("showDailyChat") private var showDailyChat = true
    @AppStorage("showMoments") private var showMoments = true
    @AppStorage("showTrackers") private var showTrackers = true
    @AppStorage("showInputs") private var showInputs = true
    @AppStorage("showBioSection") private var showBioSection = false
    @AppStorage("showGoldSection") private var showGoldSection = true

    @State private var sections: [SectionItem] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(sections) { section in
                    HStack(spacing: 12) {
                        // Toggle button on the left
                        Button(action: {
                            toggleSection(section.id)
                        }) {
                            Image(systemName: isVisible(section.id) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundStyle(isVisible(section.id) ? Color(hex: "44C0FF") : Color(.systemGray3))
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Section name
                        Text(section.name)
                            .font(.body)
                            .foregroundStyle(isVisible(section.id) ? .primary : .secondary)

                        Spacer()

                        // Drag handle on the right
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onMove { from, to in
                    sections.move(fromOffsets: from, toOffset: to)
                }
            }
            .navigationTitle("Sections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveSectionOrder()
                        dismiss()
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
        }
        .onAppear {
            loadSectionOrder()
        }
    }

    private func isVisible(_ sectionId: String) -> Bool {
        switch sectionId {
        case "dateNavigation": return showDateNavigation
        case "datePickerGrid": return showDatePickerGrid
        case "datePickerRow": return showDatePickerRow
        case "entries": return showEntries
        case "dailyEntry": return showDailyEntry
        case "dailyChat": return showDailyChat
        case "moments": return showMoments
        case "trackers": return showTrackers
        case "inputs": return showInputs
        case "bio": return showBioSection
        case "gold": return showGoldSection
        default: return false
        }
    }

    private func toggleSection(_ sectionId: String) {
        switch sectionId {
        case "dateNavigation": showDateNavigation.toggle()
        case "datePickerGrid": showDatePickerGrid.toggle()
        case "datePickerRow": showDatePickerRow.toggle()
        case "entries": showEntries.toggle()
        case "dailyEntry": showDailyEntry.toggle()
        case "dailyChat": showDailyChat.toggle()
        case "moments": showMoments.toggle()
        case "trackers": showTrackers.toggle()
        case "inputs": showInputs.toggle()
        case "bio": showBioSection.toggle()
        case "gold": showGoldSection.toggle()
        default: break
        }
    }

    private func loadSectionOrder() {
        let decoder = JSONDecoder()
        if let decodedSections = try? decoder.decode([SectionItem].self, from: sectionOrderData) {
            // Merge with allSections to add any new sections that don't exist yet
            var mergedSections = decodedSections

            // Find sections in allSections that aren't in decodedSections
            let existingIds = Set(decodedSections.map { $0.id })
            let newSections = SectionItem.allSections.filter { !existingIds.contains($0.id) }

            // Add new sections to the end
            mergedSections.append(contentsOf: newSections)

            sections = mergedSections

            // If we added new sections, save the updated order
            if !newSections.isEmpty {
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(mergedSections) {
                    sectionOrderData = encoded
                }
            }
        } else {
            sections = SectionItem.allSections
        }
    }

    private func saveSectionOrder() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(sections) {
            sectionOrderData = encoded
            // Post notification to update TodayView
            NotificationCenter.default.post(name: NSNotification.Name("SectionOrderChanged"), object: nil)
        }
    }
}

#Preview {
    TodaySectionsOrderView()
}
