import SwiftUI

// MARK: - Memory Model
struct Memory: Identifiable {
    let id = UUID()
    let content: String
}

struct DailyChatSettingsView: View {
    @AppStorage("dailyChatJournal") private var selectedJournal = "Daily"
    @AppStorage("includeBioInChatContext") private var includeBioInChatContext = false
    @AppStorage("referenceSavedMemories") private var referenceSavedMemories = true
    @State private var showingJournalPicker = false
    @State private var showingBioView = false
    @State private var showingMemoriesList = false
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
                        Text("Reference Bio")
                    }

                } header: {
                    Text("Bio")
                } footer: {
                    Text("Referencing bio can be used to improve Daily Chat sessions and responses.")
                }
                
                // Memories Section
                Section {
                    
                    NavigationLink(destination: MemoriesListView()) {
                        HStack {
                            Text("Manage Memories")
                            Spacer()
                            Text("3")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Toggle(isOn: $referenceSavedMemories) {
                        Text("Reference Memories")
                    }
                    
                } header: {
                    Text("Memories")
                } footer: {
                    Text("Memories can be used to improve Daily Chat sessions for more personalized and context-aware responses.")
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
                    .tint(Color(hex: "44C0FF"))
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

// MARK: - Memories List View
struct MemoriesListView: View {
    @State private var searchText = ""
    @State private var memories: [Memory] = [
        Memory(
            content: "I love hiking in the mountains on weekends.",
        ),
        Memory(
            content: "I have a daughter named Sarah.",
        ),
        Memory(
            content: "I'm working on improving my health by walking 3 miles every morning.",
        )
    ]
    
    var filteredMemories: [Memory] {
        if searchText.isEmpty {
            return memories
        } else {
            return memories.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            if filteredMemories.isEmpty && !searchText.isEmpty {
                ContentUnavailableView {
                    Label("No Memories Found", systemImage: "magnifyingglass")
                } description: {
                    Text("No memories match '\(searchText)'")
                }
                .listRowBackground(Color.clear)
            } else if memories.isEmpty {
                ContentUnavailableView {
                    Label("No Memories Yet", systemImage: "brain")
                } description: {
                    Text("Memories from your chats and journals will appear here")
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(filteredMemories) { memory in
                    MemoryRowView(memory: memory)
                }
                .onDelete { indexSet in
                    // Find the actual indices in the original memories array
                    for index in indexSet {
                        if let memoryToDelete = filteredMemories[safe: index],
                           let originalIndex = memories.firstIndex(where: { $0.id == memoryToDelete.id }) {
                            memories.remove(at: originalIndex)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search memories")
        .navigationTitle("Memories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !memories.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}

// MARK: - Memory Row View
struct MemoryRowView: View {
    let memory: Memory
    
    var body: some View {
        Text(memory.content)
            .font(.body)
            .lineLimit(3)
            .foregroundStyle(.primary)
            .padding(.vertical, 4)
    }
}

// Helper extension for safe array access
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        DailyChatSettingsView()
    }
}
