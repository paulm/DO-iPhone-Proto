import SwiftUI

// MARK: - Detail Settings Section Component
struct DetailSettingsSection: View {
    let sectionTitle: String
    @Binding var showCoverImage: Bool
    @Binding var useLargeListDates: Bool
    @Binding var selectedStyle: JournalDetailStyle
    @Binding var mediaViewSize: MediaViewSize
    var onPopulateEntries: ((Int) -> Void)? = nil

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

            Menu {
                Picker("Media View Size", selection: $mediaViewSize) {
                    ForEach(MediaViewSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
            } label: {
                HStack {
                    Label("Media View Size", systemImage: "square.grid.3x3")
                    Spacer()
                    Text(mediaViewSize.rawValue)
                        .foregroundStyle(.secondary)
                }
            }

            if let onPopulateEntries = onPopulateEntries {
                Menu {
                    Button("0 Entries") {
                        onPopulateEntries(0)
                    }
                    Button("1 Entry") {
                        onPopulateEntries(1)
                    }
                    Button("3 Entries") {
                        onPopulateEntries(3)
                    }
                    Button("12 Entries") {
                        onPopulateEntries(12)
                    }
                    Button("50 Entries") {
                        onPopulateEntries(50)
                    }
                    Button("100 Entries") {
                        onPopulateEntries(100)
                    }
                } label: {
                    Label("Populate Entries", systemImage: "doc.on.doc")
                }
            }
        }
    }
}
