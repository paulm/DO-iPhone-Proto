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

    // New structured sections - all strings now
    var basicInformation: [String] = []
    var relationships: [String] = []
    var keyDetails: [String] = []
    var interactions: [String] = []
    var additionalNotes: [String] = []
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
            description: "Parents, siblings, children, and extended family",
            people: [
                Person(
                    name: "Sarah Johnson",
                    relationship: "Sister",
                    notes: "Lives in Portland. Works as a graphic designer. Loves hiking and photography.",
                    isFavorite: true,
                    lastInteraction: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
                    birthday: Calendar.current.date(from: DateComponents(year: 1990, month: 7, day: 15)),
                    phoneNumber: "(503) 555-0142",
                    email: "sarah.j@email.com"
                ),
                Person(
                    name: "Jackson Mayne",
                    relationship: "Son (oldest child)",
                    notes: "",
                    isFavorite: true,
                    lastInteraction: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
                    birthday: Calendar.current.date(from: DateComponents(year: 2004, month: 1, day: 1)),
                    phoneNumber: nil,
                    email: nil,
                    basicInformation: [
                        "Age: 21",
                        "Relationship to User: Son (oldest child)",
                        "Education: Attends SLCC (Salt Lake Community College)",
                        "Living Situation: Lives in an apartment in Salt Lake City"
                    ],
                    relationships: [
                        "Girlfriend: Maddy (dating 1.5 years)"
                    ],
                    keyDetails: [],
                    interactions: [],
                    additionalNotes: [
                        "One of four Mayne children (Jackson, Eli, Dylan, Amelia)",
                        "Comes home often for Sunday Dinner"
                    ]
                ),
                Person(
                    name: "Maddy",
                    relationship: "Son Jackson's girlfriend",
                    notes: "",
                    isFavorite: false,
                    lastInteraction: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
                    birthday: nil,
                    phoneNumber: nil,
                    email: nil,
                    basicInformation: [
                        "Relationship to User: Son Jackson's girlfriend",
                        "Relationship Duration: Dating Jackson for 1.5 years"
                    ],
                    relationships: [],
                    keyDetails: [],
                    interactions: [],
                    additionalNotes: [
                        "Dating Paul's oldest son, Jackson (21)"
                    ]
                )
            ]
        ),
        PeopleCategory(
            title: "Friends",
            icon: "person.2.fill",
            color: .green,
            description: "Close friends and social connections",
            people: [
                Person(
                    name: "Marcus Chen",
                    relationship: "College Friend",
                    notes: "Met at UC Berkeley. Software engineer at a startup. Enjoys board games and craft beer.",
                    isFavorite: true,
                    lastInteraction: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()),
                    birthday: Calendar.current.date(from: DateComponents(year: 1992, month: 3, day: 22)),
                    phoneNumber: "(415) 555-0198",
                    email: "m.chen@email.com"
                )
            ]
        ),
        PeopleCategory(
            title: "Work",
            icon: "briefcase.fill",
            color: .orange,
            description: "Colleagues, managers, and professional contacts",
            people: [
                Person(
                    name: "Murphy Randle",
                    relationship: "Work contact/colleague",
                    notes: "",
                    isFavorite: false,
                    lastInteraction: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 2)),
                    birthday: nil,
                    phoneNumber: nil,
                    email: nil,
                    basicInformation: [
                        "Name: Murphy Randle",
                        "Relationship to Paul: Work contact/colleague",
                        "First Mentioned: Oct 2, 2025"
                    ],
                    relationships: [],
                    keyDetails: [
                        "Met with Paul on Oct 2, 2025 to discuss Daily Chat"
                    ],
                    interactions: [
                        "Oct 2, 2025: Meeting about Daily Chat"
                    ],
                    additionalNotes: []
                )
            ]
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
    @State private var selectedCategoryTitle: String?
    @State private var selectedPerson: Person?
    @State private var showingImportContacts = false

    private let contactsTip = ContactsConnectionTip()

    // Computed property to get all people from all categories
    var allPeople: [Person] {
        categories.flatMap { $0.people }
            .sorted { $0.name < $1.name }
    }

    // Helper to get category color for a person
    func categoryColor(for person: Person) -> Color {
        if let category = categories.first(where: { $0.people.contains(where: { $0.id == person.id }) }) {
            return category.color
        }
        return .gray
    }

    // Helper to get category title for a person
    func categoryTitle(for person: Person) -> String? {
        categories.first(where: { $0.people.contains(where: { $0.id == person.id }) })?.title
    }
    
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

                // All People List
                VStack(alignment: .leading, spacing: 12) {
                    Text("All People")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 0) {
                        ForEach(allPeople) { person in
                            Button(action: {
                                selectedPerson = person
                            }) {
                                HStack(spacing: 12) {
                                    // Person initial circle
                                    Circle()
                                        .fill(categoryColor(for: person).opacity(0.2))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Text(person.name.prefix(2).uppercased())
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(categoryColor(for: person))
                                        )

                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text(person.name)
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundStyle(.primary)

                                            if person.isFavorite {
                                                Image(systemName: "star.fill")
                                                    .font(.caption2)
                                                    .foregroundStyle(.yellow)
                                            }
                                        }

                                        Text(person.relationship)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    // Category badge
                                    if let categoryTitle = categoryTitle(for: person) {
                                        Text(categoryTitle)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundStyle(categoryColor(for: person))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(categoryColor(for: person).opacity(0.15))
                                            .clipShape(Capsule())
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(PlainButtonStyle())

                            if person.id != allPeople.last?.id {
                                Divider()
                                    .padding(.leading, 68)
                            }
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                .padding(.top, 8)

                // Categories Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(categories) { category in
                        CategoryCard(category: category) {
                            selectedCategoryTitle = category.title
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
        .sheet(item: Binding(
            get: {
                selectedCategoryTitle.flatMap { title in
                    categories.first { $0.title == title }
                }
            },
            set: { _ in selectedCategoryTitle = nil }
        )) { category in
            NavigationStack {
                CategoryDetailView(category: category, categories: $categories)
            }
        }
        .sheet(isPresented: $showingAddPerson) {
            NavigationStack {
                AddPersonView(categories: $categories)
            }
        }
        .sheet(isPresented: $showingImportContacts) {
            NavigationStack {
                ImportContactsView()
            }
        }
        .sheet(item: $selectedPerson) { person in
            NavigationStack {
                AddPersonView(editingPerson: person, category: categoryTitle(for: person) ?? "Family", categories: $categories)
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
    @Binding var categories: [PeopleCategory]
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showingAddPerson = false
    @State private var editingPerson: Person?

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
                        Button(action: {
                            editingPerson = person
                        }) {
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

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
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
                AddPersonView(category: category.title, categories: $categories)
            }
        }
        .sheet(item: $editingPerson) { person in
            NavigationStack {
                AddPersonView(editingPerson: person, category: category.title, categories: $categories)
            }
        }
    }
}

// MARK: - Add Person View
struct AddPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var person: Person
    @State private var selectedCategory: String
    @Binding var categories: [PeopleCategory]

    let categoryNames = ["Family", "Friends", "Work", "Health", "Community", "Services"]
    var isEditing: Bool

    init(editingPerson: Person? = nil, category: String = "Family", categories: Binding<[PeopleCategory]>) {
        self._categories = categories
        self._selectedCategory = State(initialValue: category)

        if let editingPerson = editingPerson {
            _person = State(initialValue: editingPerson)
            isEditing = true
        } else {
            _person = State(initialValue: Person(
                name: "",
                relationship: "",
                notes: "",
                isFavorite: false,
                lastInteraction: nil,
                birthday: nil,
                phoneNumber: nil,
                email: nil
            ))
            isEditing = false
        }
    }

    var body: some View {
        Form {
            // Core Info Section
            Section {
                TextField("Name", text: $person.name)
                TextField("Relationship", text: $person.relationship)

                Picker("Category", selection: $selectedCategory) {
                    ForEach(categoryNames, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            }

            // Basic Information Section
            Section {
                ForEach(person.basicInformation.indices, id: \.self) { index in
                    TextField("e.g., Age: 21", text: $person.basicInformation[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    person.basicInformation.remove(atOffsets: indexSet)
                }

                Button(action: {
                    person.basicInformation.append("")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
            } header: {
                Text("Basic Information")
            } footer: {
                Text("Add details like age, education, living situation, etc.")
            }

            // Relationships Section
            Section {
                ForEach(person.relationships.indices, id: \.self) { index in
                    TextField("e.g., Spouse: Jane Doe", text: $person.relationships[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    person.relationships.remove(atOffsets: indexSet)
                }

                Button(action: {
                    person.relationships.append("")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
            } header: {
                Text("Relationships")
            } footer: {
                Text("Add relationship details like spouse, siblings, children, etc.")
            }

            // Key Details Section
            Section {
                ForEach(person.keyDetails.indices, id: \.self) { index in
                    TextField("Add key detail", text: $person.keyDetails[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    person.keyDetails.remove(atOffsets: indexSet)
                }

                Button(action: {
                    person.keyDetails.append("")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
            } header: {
                Text("Key Details")
            } footer: {
                Text("Important facts or details worth remembering")
            }

            // Interactions & Memories Section
            Section {
                ForEach(person.interactions.indices, id: \.self) { index in
                    TextField("e.g., Oct 2, 2025: Coffee meeting", text: $person.interactions[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    person.interactions.remove(atOffsets: indexSet)
                }

                Button(action: {
                    person.interactions.append("")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
            } header: {
                Text("Interactions & Memories")
            } footer: {
                Text("Notable interactions, meetings, or shared memories")
            }

            // Additional Notes Section
            Section {
                ForEach(person.additionalNotes.indices, id: \.self) { index in
                    TextField("Add note", text: $person.additionalNotes[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    person.additionalNotes.remove(atOffsets: indexSet)
                }

                Button(action: {
                    person.additionalNotes.append("")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
            } header: {
                Text("Additional Notes")
            } footer: {
                Text("Any other important notes or information")
            }

            // Contact Information Section
            Section {
                TextField("Phone Number", text: Binding(
                    get: { person.phoneNumber ?? "" },
                    set: { person.phoneNumber = $0.isEmpty ? nil : $0 }
                ))
                    .keyboardType(.phonePad)

                TextField("Email", text: Binding(
                    get: { person.email ?? "" },
                    set: { person.email = $0.isEmpty ? nil : $0 }
                ))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            } header: {
                Text("Contact Information")
            }

            // Additional Details Section
            Section {
                Toggle("Mark as Favorite", isOn: $person.isFavorite)

                Toggle("Has Birthday", isOn: Binding(
                    get: { person.birthday != nil },
                    set: { hasBirthday in
                        if hasBirthday && person.birthday == nil {
                            person.birthday = Date()
                        } else if !hasBirthday {
                            person.birthday = nil
                        }
                    }
                ))

                if person.birthday != nil {
                    DatePicker("Birthday", selection: Binding(
                        get: { person.birthday ?? Date() },
                        set: { person.birthday = $0 }
                    ), displayedComponents: .date)
                }
            } header: {
                Text("Additional Details")
            }

            // Notes Section
            Section {
                TextEditor(text: $person.notes)
                    .frame(minHeight: 100)
            } header: {
                Text("Notes")
            }
        }
        .navigationTitle(isEditing ? person.name : "Add Person")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    savePerson()
                    dismiss()
                }
                .disabled(person.name.isEmpty)
            }
        }
    }

    private func savePerson() {
        // Update last interaction to now
        var updatedPerson = person
        updatedPerson.lastInteraction = Date()

        // Filter out empty strings from all sections
        updatedPerson.basicInformation = updatedPerson.basicInformation.filter { !$0.isEmpty }
        updatedPerson.relationships = updatedPerson.relationships.filter { !$0.isEmpty }
        updatedPerson.keyDetails = updatedPerson.keyDetails.filter { !$0.isEmpty }
        updatedPerson.interactions = updatedPerson.interactions.filter { !$0.isEmpty }
        updatedPerson.additionalNotes = updatedPerson.additionalNotes.filter { !$0.isEmpty }

        // Find the category index
        if let categoryIndex = categories.firstIndex(where: { $0.title == selectedCategory }) {
            if isEditing {
                // Remove from all categories first
                for i in categories.indices {
                    categories[i].people.removeAll { $0.id == person.id }
                }
            }
            // Add to selected category
            categories[categoryIndex].people.append(updatedPerson)
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