import SwiftUI

struct TravelView: View {
    @State private var bioData = BioData.shared
    @State private var showingAddTravel = false
    @State private var editingTravel: Travel?
    @State private var selectedTab = 0 // 0 = Past, 1 = Future
    
    var pastTravels: [Travel] {
        bioData.travels
            .filter { !$0.isFutureTrip }
            .sorted { $0.startDate > $1.startDate }
    }
    
    var futureTravels: [Travel] {
        bioData.travels
            .filter { $0.isFutureTrip }
            .sorted { $0.startDate < $1.startDate }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("Travel Type", selection: $selectedTab) {
                Text("Past Trips").tag(0)
                Text("Future Plans").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            List {
                if selectedTab == 0 {
                    // Past Trips
                    if pastTravels.isEmpty {
                        Section {
                            VStack(spacing: 16) {
                                Image(systemName: "airplane.departure")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.secondary)
                                
                                Text("No past trips")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                
                                Text("Add your travel memories and adventures")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Add Past Trip") {
                                    showingAddTravel = true
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(pastTravels) { travel in
                            TravelRow(travel: travel) {
                                editingTravel = travel
                            } onDelete: {
                                if let index = bioData.travels.firstIndex(where: { $0.id == travel.id }) {
                                    bioData.travels.remove(at: index)
                                }
                            }
                        }
                    }
                } else {
                    // Future Plans
                    if futureTravels.isEmpty {
                        Section {
                            VStack(spacing: 16) {
                                Image(systemName: "airplane.arrival")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.secondary)
                                
                                Text("No future trips planned")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                
                                Text("Plan your next adventure or vacation")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Plan Future Trip") {
                                    showingAddTravel = true
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(futureTravels) { travel in
                            TravelRow(travel: travel) {
                                editingTravel = travel
                            } onDelete: {
                                if let index = bioData.travels.firstIndex(where: { $0.id == travel.id }) {
                                    bioData.travels.remove(at: index)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Travel")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddTravel = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTravel) {
            NavigationStack {
                AddTravelView(isFutureTrip: selectedTab == 1)
            }
        }
        .sheet(item: $editingTravel) { travel in
            NavigationStack {
                AddTravelView(editingTravel: travel)
            }
        }
    }
}

// MARK: - Travel Row Component
struct TravelRow: View {
    let travel: Travel
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Travel photo or placeholder
            if let photoData = travel.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: travel.isFutureTrip ? "airplane" : "map.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(travel.destination)
                        .font(.headline)
                    
                    if travel.isOngoing {
                        Text("NOW")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                }
                
                Text("\(travel.country) • \(travel.purpose)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(travel.dateRange)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    Text("•")
                        .foregroundStyle(.tertiary)
                    
                    Text(travel.duration)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    if !travel.isFutureTrip && travel.rating > 0 {
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= travel.rating ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundStyle(star <= travel.rating ? .yellow : .gray.opacity(0.3))
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Travel View
struct AddTravelView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var travel: Travel
    @State private var bioData = BioData.shared
    @State private var showingImagePicker = false
    
    let purposes = ["Vacation", "Business", "Family Visit", "Adventure", "Education", "Medical", "Other"]
    
    var isEditing: Bool
    
    init(editingTravel: Travel? = nil, isFutureTrip: Bool = false) {
        if let editingTravel = editingTravel {
            _travel = State(initialValue: editingTravel)
            isEditing = true
        } else {
            var newTravel = Travel()
            newTravel.isFutureTrip = isFutureTrip
            _travel = State(initialValue: newTravel)
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
                        if let photoData = travel.photoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 120, height: 80)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Image(systemName: "camera.fill")
                                            .font(.title3)
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
                TextField("Destination (City/Place)", text: $travel.destination)
                TextField("Country", text: $travel.country)
                
                Picker("Purpose", selection: $travel.purpose) {
                    ForEach(purposes, id: \.self) { purpose in
                        Text(purpose).tag(purpose)
                    }
                }
                
                Toggle("Future Trip", isOn: $travel.isFutureTrip)
            } header: {
                Text("Trip Details")
            }
            
            Section {
                DatePicker("Start Date", selection: $travel.startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $travel.endDate, displayedComponents: .date)
            } header: {
                Text("Dates")
            }
            
            Section {
                TextField("Travel Companions", text: $travel.companions)
                TextField("Accommodation", text: $travel.accommodation)
            } header: {
                Text("Travel Info")
            }
            
            if !travel.isFutureTrip {
                Section {
                    HStack {
                        Text("Rating")
                        Spacer()
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= travel.rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(star <= travel.rating ? .yellow : .gray.opacity(0.3))
                                    .onTapGesture {
                                        travel.rating = star
                                    }
                            }
                        }
                    }
                } header: {
                    Text("Experience")
                }
            }
            
            Section {
                TextField("Trip highlights or must-see places", text: $travel.highlights, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                
                TextField("Notes", text: $travel.notes, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
            } header: {
                Text(travel.isFutureTrip ? "Planning Notes" : "Memories")
            }
        }
        .navigationTitle(isEditing ? "Edit Trip" : (travel.isFutureTrip ? "Plan Trip" : "Add Trip"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if isEditing {
                        // Update existing travel
                        if let index = bioData.travels.firstIndex(where: { $0.id == travel.id }) {
                            bioData.travels[index] = travel
                        }
                    } else {
                        // Add new travel
                        bioData.travels.append(travel)
                    }
                    dismiss()
                }
                .disabled(travel.destination.isEmpty || travel.country.isEmpty)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            TravelImagePickerPlaceholder(travelImage: $travel.photoData)
        }
    }
}


struct TravelImagePickerPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var travelImage: Data?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
                
                Text("Travel Photo")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Add a photo from your trip")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button("Take Photo") {
                        // Camera functionality would go here
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Choose from Library") {
                        // Photo library functionality would go here
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    if travelImage != nil {
                        Button("Remove Photo") {
                            travelImage = nil
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

