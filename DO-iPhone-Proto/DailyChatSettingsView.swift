import SwiftUI

struct DailyChatSettingsView: View {
    @AppStorage("dailyChatJournal") private var selectedJournal = "Daily"
    @AppStorage("includeBioInChatContext") private var includeBioInChatContext = false
    @State private var showingJournalPicker = false
    @State private var showingBioView = false
    @Environment(\.dismiss) private var dismiss
    
    // Sample journals for selection
    private let availableJournals = ["Daily", "Personal", "Work", "Travel", "Fitness", "Gratitude"]
    
    var body: some View {
        NavigationStack {
            List {
                // Journal Section
                Section {
                    NavigationLink(destination: JournalPickerView(selectedJournal: $selectedJournal)) {
                        Text("Journal")
                    }
                } header: {
                    Text("Journal")
                } footer: {
                    Text("The assigned journal is where your Daily Chat entries will be saved.")
                }
                
                // Bio Section
                Section {
                    NavigationLink(destination: BioEditView()) {
                        Text("Edit Bio")
                    }
                    
                    Toggle(isOn: $includeBioInChatContext) {
                        Text("Include Bio in Chat Context")
                    }
                } header: {
                    Text("Bio")
                } footer: {
                    Text("Contexts are used by Day One AI to improve its responses across all Daily Chat sessions.")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Chat Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                    .labelStyle(.titleAndIcon)
                    .tint(Color(hex: "333B40"))
                }
            }
        }
    }
}

struct JournalPickerView: View {
    @Binding var selectedJournal: String
    @Environment(\.dismiss) private var dismiss
    
    private let availableJournals = ["Daily", "Personal", "Work", "Travel", "Fitness", "Gratitude"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableJournals, id: \.self) { journal in
                    HStack {
                        Text(journal)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if selectedJournal == journal {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(hex: "44C0FF"))
                                .fontWeight(.semibold)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedJournal = journal
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DailyChatSettingsView()
    }
}