import SwiftUI
import TipKit

// MARK: - People Category Model
struct PeopleCategory: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    var people: [Person] = []
}

// MARK: - Person Model
struct Person: Identifiable {
    let id = UUID()
    var name: String
    var relationship: String
    var notes: String
    var isFavorite: Bool = false
    var lastInteraction: Date?
    var birthday: Date?
    var phoneNumber: String?
    var email: String?
}

// MARK: - Contacts Connection Tip
struct ContactsConnectionTip: Tip {
    var title: Text {
        Text("Connect to Contacts")
    }
    
    var message: Text? {
        Text("Import people from your Contacts app to quickly add family, friends, and colleagues. Your journal entries can reference these connections for richer memories.")
    }
    
    var image: Image? {
        Image(systemName: "person.crop.circle.badge.plus")
    }
    
    var actions: [Action] {
        Action(id: "connect", title: "Connect Contacts")
        Action(id: "dismiss", title: "Not Now")
    }
}

// MARK: - People View
struct PeopleView: View {
    @State private var categories: [PeopleCategory] = [
        PeopleCategory(
            title: "Family",
            icon: "figure.2.and.child.holdinghands",
            color: .blue,
            description: "Parents, siblings, children, and extended family"
        ),
        PeopleCategory(
            title: "Friends",
            icon: "person.2.fill",
            color: .green,
            description: "Close friends and social connections"
        ),
        PeopleCategory(
            title: "Work",
            icon: "briefcase.fill",
            color: .orange,
            description: "Colleagues, managers, and professional contacts"
        ),
        PeopleCategory(
            title: "Health",
            icon: "heart.text.square.fill",
            color: .red,
            description: "Doctors, therapists, and health professionals"
        ),
        PeopleCategory(
            title: "Community",
            icon: "person.3.fill",
            color: .purple,
            description: "Neighbors, community members, and acquaintances"
        ),
        PeopleCategory(
            title: "Services",
            icon: "wrench.and.screwdriver.fill",
            color: .indigo,
            description: "Service providers and business contacts"
        )
    ]
    
    @State private var searchText = ""
    @State private var showingAddPerson = false
    @State private var selectedCategory: PeopleCategory?
    @State private var showingImportContacts = false
    
    private let contactsTip = ContactsConnectionTip()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundStyle(Color(hex: "44C0FF"))
                        .symbolRenderingMode(.hierarchical)
                    
                    Text("People in Your Life")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Organize and track important relationships")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Contacts Connection Tip
                TipView(contactsTip, arrowEdge: .top) { action in
                    if action.id == "connect" {
                        showingImportContacts = true
                        contactsTip.invalidate(reason: .actionPerformed)
                    } else if action.id == "dismiss" {
                        contactsTip.invalidate(reason: .tipClosed)
                    }
                }
                .padding(.horizontal)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Search people", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                // Categories Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(categories) { category in
                        CategoryCard(category: category) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
                
                // Quick Actions
                VStack(spacing: 12) {
                    Button(action: {
                        showingAddPerson = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color(hex: "44C0FF"))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Add Person")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Manually add someone to your network")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(.tertiary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        showingImportContacts = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Import from Contacts")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Sync with your device contacts")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(.tertiary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                
                // Recent Interactions Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Interactions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { index in
                                RecentPersonCard(index: index)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("People")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // Sort by name
                    }) {
                        Label("Sort by Name", systemImage: "arrow.up.arrow.down")
                    }
                    
                    Button(action: {
                        // Sort by recent
                    }) {
                        Label("Sort by Recent", systemImage: "clock")
                    }
                    
                    Divider()
                    
                    Button(action: {
                        // Export
                    }) {
                        Label("Export People", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $selectedCategory) { category in
            NavigationStack {
                CategoryDetailView(category: category)
            }
        }
        .sheet(isPresented: $showingAddPerson) {
            NavigationStack {
                AddPersonView()
            }
        }
        .sheet(isPresented: $showingImportContacts) {
            NavigationStack {
                ImportContactsView()
            }
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: PeopleCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(category.color)
                
                Text(category.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("\(category.people.count) people")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(category.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recent Person Card
struct RecentPersonCard: View {
    let index: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(["JD", "AS", "MK", "RP", "TL"][index])
                        .font(.headline)
                        .foregroundStyle(.secondary)
                )
            
            Text(["John Doe", "Alice Smith", "Mike Kim", "Rachel Park", "Tom Lee"][index])
                .font(.caption)
                .lineLimit(1)
                .foregroundStyle(.primary)
            
            Text(["2 days ago", "1 week ago", "2 weeks ago", "1 month ago", "2 months ago"][index])
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 80)
    }
}

// MARK: - Category Detail View
struct CategoryDetailView: View {
    let category: PeopleCategory
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showingAddPerson = false
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: category.icon)
                            .font(.title2)
                            .foregroundStyle(category.color)
                        
                        Text(category.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Text(category.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("\(category.people.count) people in this category")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)
            
            if category.people.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        
                        Text("No people yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Add people to this category to start tracking your relationships")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add First Person") {
                            showingAddPerson = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(category.people) { person in
                        HStack {
                            Circle()
                                .fill(category.color.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(person.name.prefix(2).uppercased())
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(category.color)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(person.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Text(person.relationship)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if person.isFavorite {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundStyle(.yellow)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("People")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search \(category.title.lowercased())")
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddPerson = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPerson) {
            NavigationStack {
                AddPersonView()
            }
        }
    }
}

// MARK: - Add Person View
struct AddPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var relationship = ""
    @State private var notes = ""
    @State private var selectedCategory = "Family"
    @State private var isFavorite = false
    @State private var birthday = Date()
    @State private var hasBirthday = false
    
    let categories = ["Family", "Friends", "Work", "Health", "Community", "Services"]
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("Relationship", text: $relationship)
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            } header: {
                Text("Basic Information")
            }
            
            Section {
                TextField("Phone Number", text: .constant(""))
                    .keyboardType(.phonePad)
                
                TextField("Email", text: .constant(""))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            } header: {
                Text("Contact Information")
            }
            
            Section {
                Toggle("Mark as Favorite", isOn: $isFavorite)
                
                Toggle("Has Birthday", isOn: $hasBirthday)
                
                if hasBirthday {
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                }
            } header: {
                Text("Additional Details")
            }
            
            Section {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            } header: {
                Text("Notes")
            }
        }
        .navigationTitle("Add Person")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Save person logic
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
    }
}

// MARK: - Import Contacts View
struct ImportContactsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedContacts: Set<String> = []
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                    .symbolRenderingMode(.hierarchical)
                
                Text("Import from Contacts")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select contacts to add to your journal's people network")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 24)
            .background(Color(.systemGroupedBackground))
            
            // Contacts list placeholder
            List {
                Section {
                    ForEach(["John Appleseed", "Kate Bell", "Anna Haro", "Daniel Higgins", "David Taylor"], id: \.self) { name in
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(name.split(separator: " ").map { $0.prefix(1) }.joined())
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                )
                            
                            VStack(alignment: .leading) {
                                Text(name)
                                    .font(.body)
                                
                                Text("Mobile: (555) 555-5555")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedContacts.contains(name) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedContacts.contains(name) {
                                selectedContacts.remove(name)
                            } else {
                                selectedContacts.insert(name)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            
            // Bottom action bar
            VStack(spacing: 16) {
                Text("\(selectedContacts.count) contacts selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    Button("Select All") {
                        selectedContacts = Set(["John Appleseed", "Kate Bell", "Anna Haro", "Daniel Higgins", "David Taylor"])
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Import \(selectedContacts.count) Contacts") {
                        // Import logic
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedContacts.isEmpty)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -4)
        }
        .navigationTitle("Select Contacts")
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

#Preview {
    NavigationStack {
        PeopleView()
    }
}