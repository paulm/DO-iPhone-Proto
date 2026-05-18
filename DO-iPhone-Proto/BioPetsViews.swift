import SwiftUI

struct PetsView: View {
    @State private var bioData = BioData.shared
    @State private var showingAddPet = false
    @State private var editingPet: Pet?
    
    var sortedPets: [Pet] {
        bioData.pets.sorted { pet1, pet2 in
            if pet1.hasBirthday && pet2.hasBirthday {
                return pet1.birthday < pet2.birthday
            } else if pet1.hasBirthday {
                return true
            } else {
                return false
            }
        }
    }
    
    var body: some View {
        List {
            if bioData.pets.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        Text("No pets added")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Add your furry, feathered, or scaly friends")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add Pet") {
                            showingAddPet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(sortedPets) { pet in
                    Button(action: {
                        editingPet = pet
                    }) {
                        HStack(spacing: 12) {
                            // Pet photo or placeholder
                            if let photoData = pet.photoData,
                               let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "pawprint.fill")
                                            .font(.title2)
                                            .foregroundStyle(.gray)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(pet.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                HStack {
                                    Text("\(pet.gender) \(pet.type)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    if !pet.isAlive {
                                        Image(systemName: "heart")
                                            .font(.caption)
                                            .foregroundStyle(.red)
                                    }
                                }

                                Text(pet.age)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive, action: {
                            if let index = bioData.pets.firstIndex(where: { $0.id == pet.id }) {
                                bioData.pets.remove(at: index)
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Pets")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddPet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPet) {
            NavigationStack {
                AddPetView()
            }
        }
        .sheet(item: $editingPet) { pet in
            NavigationStack {
                AddPetView(editingPet: pet)
            }
        }
    }
}

// MARK: - Add Pet View
struct AddPetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pet: Pet
    @State private var bioData = BioData.shared
    @State private var showingImagePicker = false
    
    var isEditing: Bool
    
    init(editingPet: Pet? = nil) {
        if let editingPet = editingPet {
            _pet = State(initialValue: editingPet)
            isEditing = true
        } else {
            _pet = State(initialValue: Pet())
            isEditing = false
        }
    }
    
    var body: some View {
        Form {
            Section {
                // Photo picker
                HStack {
                    Spacer()
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        if let photoData = pet.photoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Image(systemName: "camera.fill")
                                            .font(.title2)
                                            .foregroundStyle(.gray)
                                        Text("Add Photo")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    }
                                )
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            
            Section {
                TextField("Name", text: $pet.name)
                TextField("Type (e.g., Dog, Cat, Bird)", text: $pet.type)

                Picker("Gender", selection: $pet.gender) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                }

                TextField("Color", text: $pet.color)
                TextField("Weight", text: $pet.weight)
                    .keyboardType(.decimalPad)

                ForEach(pet.basicInformation.indices, id: \.self) { index in
                    TextField("e.g., Breed: Golden Retriever", text: $pet.basicInformation[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    pet.basicInformation.remove(atOffsets: indexSet)
                }

                Button(action: {
                    pet.basicInformation.append("")
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
                Text("Add details like breed, age when adopted, microchip number, etc.")
            }

            Section {
                Toggle("Has Birthday", isOn: $pet.hasBirthday)

                if pet.hasBirthday {
                    DatePicker("Birthday", selection: $pet.birthday, displayedComponents: .date)
                }

                Toggle("Has Passed Away", isOn: $pet.hasDeathDate)

                if pet.hasDeathDate {
                    DatePicker("Death Date", selection: $pet.deathDate, displayedComponents: .date)
                }

                ForEach(pet.importantDates.indices, id: \.self) { index in
                    TextField("e.g., Adopted: Jan 15, 2020", text: $pet.importantDates[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    pet.importantDates.remove(atOffsets: indexSet)
                }

                Button(action: {
                    pet.importantDates.append("")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
            } header: {
                Text("Important Dates")
            } footer: {
                Text("Add other important dates like adoption day, vet visits, etc.")
            }

            // Health Information Section
            Section {
                ForEach(pet.healthInformation.indices, id: \.self) { index in
                    TextField("e.g., Vaccinated: Yes (2024)", text: $pet.healthInformation[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    pet.healthInformation.remove(atOffsets: indexSet)
                }

                Button(action: {
                    pet.healthInformation.append("")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
            } header: {
                Text("Health Information")
            } footer: {
                Text("Track vaccinations, medications, vet visits, allergies, etc.")
            }

            // Behavior & Traits Section
            Section {
                ForEach(pet.behaviorTraits.indices, id: \.self) { index in
                    TextField("e.g., Loves to play fetch", text: $pet.behaviorTraits[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    pet.behaviorTraits.remove(atOffsets: indexSet)
                }

                Button(action: {
                    pet.behaviorTraits.append("")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
            } header: {
                Text("Behavior & Traits")
            } footer: {
                Text("Personality traits, favorite activities, quirks, etc.")
            }

            // Memories & Milestones Section
            Section {
                ForEach(pet.memoriesAndMilestones.indices, id: \.self) { index in
                    TextField("e.g., First day home: Jan 15, 2020", text: $pet.memoriesAndMilestones[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    pet.memoriesAndMilestones.remove(atOffsets: indexSet)
                }

                Button(action: {
                    pet.memoriesAndMilestones.append("")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
            } header: {
                Text("Memories & Milestones")
            } footer: {
                Text("Special moments, achievements, funny stories, etc.")
            }

            Section {
                TextField("General notes about your pet", text: $pet.notes, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
            } header: {
                Text("Notes")
            }

            // Additional Notes Section
            Section {
                ForEach(pet.additionalNotes.indices, id: \.self) { index in
                    TextField("Add note", text: $pet.additionalNotes[index])
                        .foregroundStyle(.primary)
                }
                .onDelete { indexSet in
                    pet.additionalNotes.remove(atOffsets: indexSet)
                }

                Button(action: {
                    pet.additionalNotes.append("")
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
                Text("Any other important information about your pet")
            }
        }
        .navigationTitle(isEditing ? "Edit Pet" : "Add Pet")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Filter out empty strings from all sections
                    pet.basicInformation = pet.basicInformation.filter { !$0.isEmpty }
                    pet.healthInformation = pet.healthInformation.filter { !$0.isEmpty }
                    pet.behaviorTraits = pet.behaviorTraits.filter { !$0.isEmpty }
                    pet.memoriesAndMilestones = pet.memoriesAndMilestones.filter { !$0.isEmpty }
                    pet.importantDates = pet.importantDates.filter { !$0.isEmpty }
                    pet.additionalNotes = pet.additionalNotes.filter { !$0.isEmpty }

                    if isEditing {
                        // Update existing pet
                        if let index = bioData.pets.firstIndex(where: { $0.id == pet.id }) {
                            bioData.pets[index] = pet
                        }
                    } else {
                        // Add new pet
                        bioData.pets.append(pet)
                    }
                    dismiss()
                }
                .disabled(pet.name.isEmpty || pet.type.isEmpty)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            PetImagePickerPlaceholder(petImage: $pet.photoData)
        }
    }
}

// MARK: - Pet Image Picker Placeholder
struct PetImagePickerPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var petImage: Data?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
                
                Text("Pet Photo")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Image picker functionality would be implemented here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button("Take Photo") {
                        // Camera functionality would go here
                        // For now, just set a placeholder
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Choose from Library") {
                        // Photo library functionality would go here
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    if petImage != nil {
                        Button("Remove Photo") {
                            petImage = nil
                            dismiss()
                        }
                        .foregroundStyle(.red)
                    }
                }
                .padding(.top, 20)
            }
            .padding()
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

