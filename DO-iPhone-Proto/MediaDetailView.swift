import SwiftUI
import MapKit

struct MediaDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var caption: String = ""
    @State private var showingMenu = false
    @FocusState private var isCaptionFocused: Bool
    
    let imageName: String
    let imageDate: Date
    let locationName: String
    let locationCoordinate: CLLocationCoordinate2D
    
    private let mediaDescription = """
A scenic mountain vista captured during an early morning hike. The image shows a winding trail cutting through dense forest, with golden aspen trees in the foreground creating a striking contrast against the darker evergreen pines. The morning light filters through the canopy, creating dappled shadows on the path below. In the distance, mountain peaks are visible through a slight haze, their rocky faces catching the warm light of sunrise. The composition captures the serene beauty of the natural landscape, with the trail serving as a leading line that draws the eye deeper into the wilderness. The autumn colors suggest this was taken during peak fall foliage season, when the aspens transform the mountainside into a patchwork of gold and green.
"""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Date, time and location header
                    HStack {
                        Text("\(imageDate, format: .dateTime.weekday(.wide).month(.wide).day()) at \(imageDate, format: .dateTime.hour().minute()) · \(locationName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
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
                            
                            Menu {
                                Button(action: {
                                    // Process again action
                                }) {
                                    Label("Process again", systemImage: "arrow.clockwise")
                                }
                                
                                Button(role: .destructive, action: {
                                    // Delete description action
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
                        }
                        
                        Text(mediaDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding()
                }
            }
            .navigationTitle("Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    MediaDetailView(
        imageName: "bike-wide",
        imageDate: Date(),
        locationName: "Sundance Resort",
        locationCoordinate: CLLocationCoordinate2D(latitude: 40.6006, longitude: -111.5878)
    )
}