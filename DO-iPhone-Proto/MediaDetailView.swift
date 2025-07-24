import SwiftUI
import MapKit

struct MediaDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var caption: String = ""
    @State private var showingMenu = false
    @State private var hasDescription = false
    @State private var isGeneratingDescription = false
    @State private var generatedDescription = ""
    @FocusState private var isCaptionFocused: Bool
    
    let imageName: String
    let imageDate: Date
    let locationName: String
    let locationCoordinate: CLLocationCoordinate2D
    
    private let fullDescription = """
A meticulously restored vintage bicycle is parked curbside in front of a stylish café or boutique shop. The chrome frame gleams in the daylight, complemented by tan wall tires, a brown leather saddle, and matching leather-wrapped handlebars. Mounted on the rear rack is a wooden storage box with leather accents, while two polished gold water bottles are secured to the frame. A small wooden crate with vintage accessories rests beneath the bike, enhancing its nostalgic charm. The warm, wood-paneled storefront in the background, filled with bottles and soft lighting, completes the inviting, retro-modern aesthetic.
"""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Image thumbnail section
                    VStack(spacing: 16) {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Caption input field
                        TextField("Add a caption...", text: $caption, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(UIColor.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .focused($isCaptionFocused)
                            .lineLimit(3...6)
                    }
                    .padding()
                    .background(Color.white)
                    
                    // Media Description section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("MEDIA DESCRIPTION")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            if hasDescription {
                                Menu {
                                    Button(action: {
                                        // Process again - regenerate description
                                        hasDescription = false
                                        generatedDescription = ""
                                        generateDescription()
                                    }) {
                                        Label("Process again", systemImage: "arrow.clockwise")
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        // Delete description
                                        hasDescription = false
                                        generatedDescription = ""
                                    }) {
                                        Label("Delete description", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                            } else if !isGeneratingDescription {
                                Button(action: generateDescription) {
                                    Text("Generate")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        
                        if hasDescription {
                            Text(generatedDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else if isGeneratingDescription {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Generating description...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.vertical, 30)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(imageDate, format: .dateTime.weekday(.wide).month(.wide).day().year())
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("\(imageDate, format: .dateTime.hour().minute()) at \(locationName)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func generateDescription() {
        isGeneratingDescription = true
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            generatedDescription = fullDescription
            hasDescription = true
            isGeneratingDescription = false
        }
    }
}

#Preview {
    // Create a specific date: Tuesday, July 22, 2025 at 3:14 PM
    let components = DateComponents(
        year: 2025,
        month: 7,
        day: 22,
        hour: 15,
        minute: 14
    )
    let specificDate = Calendar.current.date(from: components) ?? Date()
    
    return MediaDetailView(
        imageName: "bike-wide",
        imageDate: specificDate,
        locationName: "Sundance Resort",
        locationCoordinate: CLLocationCoordinate2D(latitude: 40.6006, longitude: -111.5878)
    )
}