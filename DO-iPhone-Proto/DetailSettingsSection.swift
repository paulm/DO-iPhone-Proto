import SwiftUI

// MARK: - Detail Settings Section Component
struct DetailSettingsSection: View {
    let sectionTitle: String
    @Binding var showCoverImage: Bool
    @Binding var useLargeListDates: Bool
    @Binding var selectedStyle: JournalDetailStyle

    var body: some View {
        Section(sectionTitle) {
            Toggle(isOn: $showCoverImage) {
                Label("Show Cover Image", systemImage: "photo")
            }

            Toggle(isOn: $useLargeListDates) {
                Label("Large List Dates", systemImage: "calendar")
            }

            Menu {
                Picker("Style", selection: $selectedStyle) {
                    ForEach(JournalDetailStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
            } label: {
                HStack {
                    Label("Style", systemImage: "paintbrush")
                    Spacer()
                    Text(selectedStyle.rawValue)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
