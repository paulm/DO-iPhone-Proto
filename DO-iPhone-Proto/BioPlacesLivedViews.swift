import SwiftUI

struct PlacesLivedView: View {
    @State private var bioData = BioData.shared
    @State private var showingAddPlace = false
    @State private var editingPlace: PlaceLived?
    
    var body: some View {
        List {
            if bioData.placesLived.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        Text("No places added")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Add the places you've lived to tell your story")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add Place") {
                            showingAddPlace = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(bioData.placesLived) { place in
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if !place.placeName.isEmpty {
                                Text(place.placeName)
                                    .font(.headline)
                                Text(place.city)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(place.city)
                                    .font(.headline)
                            }
                            
                            if place.stillLivingThere {
                                if !place.movedInYear.isEmpty {
                                    Text("\(place.movedInMonth.isEmpty ? "" : place.movedInMonth + " ")\(place.movedInYear) - Present")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                } else {
                                    Text("Currently living here")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            } else {
                                let movedIn = "\(place.movedInMonth.isEmpty ? "" : place.movedInMonth + " ")\(place.movedInYear)"
                                let movedOut = "\(place.movedOutMonth.isEmpty ? "" : place.movedOutMonth + " ")\(place.movedOutYear)"
                                
                                if !place.movedInYear.isEmpty || !place.movedOutYear.isEmpty {
                                    Text("\(movedIn.isEmpty ? "?" : movedIn) - \(movedOut.isEmpty ? "?" : movedOut)")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button(action: {
                                editingPlace = place
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: {
                                if let index = bioData.placesLived.firstIndex(where: { $0.id == place.id }) {
                                    bioData.placesLived.remove(at: index)
                                }
                            }) {
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
        }
        .navigationTitle("Places Lived")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddPlace = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPlace) {
            NavigationStack {
                AddPlaceLivedView()
            }
        }
        .sheet(item: $editingPlace) { place in
            NavigationStack {
                AddPlaceLivedView(editingPlace: place)
            }
        }
    }
}

// MARK: - Add Place Lived View
struct AddPlaceLivedView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var place: PlaceLived
    @State private var bioData = BioData.shared
    
    let years = [""] + Array(1900...2030).reversed().map { String($0) }
    let months = ["", "January", "February", "March", "April", "May", "June", 
                  "July", "August", "September", "October", "November", "December"]
    
    var isEditing: Bool
    
    init(editingPlace: PlaceLived? = nil) {
        if let editingPlace = editingPlace {
            _place = State(initialValue: editingPlace)
            isEditing = true
        } else {
            _place = State(initialValue: PlaceLived())
            isEditing = false
        }
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Place Name", text: $place.placeName)
                TextField("City", text: $place.city)
            } header: {
                Text("Places lived")
            }
            
            Section {
                HStack {
                    Picker("Year", selection: $place.movedInYear) {
                        Text("Year").tag("")
                        ForEach(years.filter { !$0.isEmpty }, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Month", selection: $place.movedInMonth) {
                        Text("Month").tag("")
                        ForEach(months.filter { !$0.isEmpty }, id: \.self) { month in
                            Text(month).tag(month)
                        }
                    }
                    .pickerStyle(.menu)
                }
            } header: {
                Text("Moved In")
            }
            
            Section {
                Toggle("Still living there", isOn: $place.stillLivingThere)
                
                if !place.stillLivingThere {
                    HStack {
                        Picker("Year", selection: $place.movedOutYear) {
                            Text("Year").tag("")
                            ForEach(years.filter { !$0.isEmpty }, id: \.self) { year in
                                Text(year).tag(year)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Picker("Month", selection: $place.movedOutMonth) {
                            Text("Month").tag("")
                            ForEach(months.filter { !$0.isEmpty }, id: \.self) { month in
                                Text(month).tag(month)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            } header: {
                Text("Moved Out")
            }
        }
        .navigationTitle(isEditing ? "Edit Place" : "Add Place")
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
                        // Update existing place
                        if let index = bioData.placesLived.firstIndex(where: { $0.id == place.id }) {
                            bioData.placesLived[index] = place
                        }
                    } else {
                        // Add new place
                        bioData.placesLived.append(place)
                    }
                    dismiss()
                }
                .disabled(place.city.isEmpty)
            }
        }
    }
}

