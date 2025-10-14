//
//  ImageGenerationView.swift
//  DO-iPhone-Proto
//

import SwiftUI
import PhotosUI

struct ImageGenerationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isSharePresented: Bool = false
    @State private var shareImage: UIImage?
    @State private var selectedStyle: ImageStyle = .lineArt

    // Three separate sets of images for each row
    @State private var row1Images: [GeneratedImage] = [
        GeneratedImage(isLoading: false, image: nil),
        GeneratedImage(isLoading: false, image: nil)
    ]
    @State private var row2Images: [GeneratedImage] = [
        GeneratedImage(isLoading: false, image: nil),
        GeneratedImage(isLoading: false, image: nil)
    ]
    @State private var row3Images: [GeneratedImage] = [
        GeneratedImage(isLoading: false, image: nil),
        GeneratedImage(isLoading: false, image: nil)
    ]

    @State private var row1CurrentPage: Int = 0
    @State private var row2CurrentPage: Int = 0
    @State private var row3CurrentPage: Int = 0

    // Define accent color
    let accentColor = Color(hex: "44C0FF")

    // Available styles
    let styles: [ImageStyle] = [
        .lineArt, .threeD, .analogFilm, .anime, .cinematic,
        .comicbook, .craftClay, .digitalArt, .enhance, .fantasyArt,
        .isometric, .lowpoly, .neonpunk,
        .origami, .photographic, .pixelArt, .texture
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    // Row 1
                    ImageCarouselRow(
                        images: $row1Images,
                        currentPage: $row1CurrentPage,
                        accentColor: accentColor,
                        rowNumber: 1,
                        onDismiss: { dismiss() },
                        onShare: { image in
                            shareImage = image
                            isSharePresented = true
                        }
                    )

                    // Row 2
                    ImageCarouselRow(
                        images: $row2Images,
                        currentPage: $row2CurrentPage,
                        accentColor: accentColor,
                        rowNumber: 2,
                        onDismiss: { dismiss() },
                        onShare: { image in
                            shareImage = image
                            isSharePresented = true
                        }
                    )

                    // Row 3
                    ImageCarouselRow(
                        images: $row3Images,
                        currentPage: $row3CurrentPage,
                        accentColor: accentColor,
                        rowNumber: 3,
                        onDismiss: { dismiss() },
                        onShare: { image in
                            shareImage = image
                            isSharePresented = true
                        }
                    )

                    // Style picker section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Style")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(styles, id: \.self) { style in
                                    StyleButton(style: style, isSelected: selectedStyle == style) {
                                        selectedStyle = style
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedStyle) { oldValue, newValue in
                // When style changes, advance all 3 carousels to next empty spot
                advanceAllCarouselsToNextEmpty()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(accentColor)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $isSharePresented) {
            if let imageToShare = shareImage {
                ActivityViewController(activityItems: [imageToShare])
            }
        }
    }

    // Helper method to advance all carousels to next empty spot
    private func advanceAllCarouselsToNextEmpty() {
        // Find next available placeholder in each row
        let row1NextIndex = findNextAvailablePlaceholder(in: row1Images)
        let row2NextIndex = findNextAvailablePlaceholder(in: row2Images)
        let row3NextIndex = findNextAvailablePlaceholder(in: row3Images)

        // Pre-mark as loading to prevent flashing
        if row1NextIndex < row1Images.count && !row1Images[row1NextIndex].isLoading {
            row1Images[row1NextIndex].isLoading = true
        }
        if row2NextIndex < row2Images.count && !row2Images[row2NextIndex].isLoading {
            row2Images[row2NextIndex].isLoading = true
        }
        if row3NextIndex < row3Images.count && !row3Images[row3NextIndex].isLoading {
            row3Images[row3NextIndex].isLoading = true
        }

        // Animate to those placeholders
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            row1CurrentPage = row1NextIndex
            row2CurrentPage = row2NextIndex
            row3CurrentPage = row3NextIndex
        }

        // Trigger generation after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generateImageForRow(row: 1, index: row1NextIndex)
            generateImageForRow(row: 2, index: row2NextIndex)
            generateImageForRow(row: 3, index: row3NextIndex)
        }
    }

    // Find the next available placeholder in an array
    private func findNextAvailablePlaceholder(in images: [GeneratedImage]) -> Int {
        // First look for any existing placeholder
        for (index, image) in images.enumerated() {
            if image.image == nil && !image.isLoading {
                return index
            }
        }
        // If no placeholder exists, return the last index
        return images.count - 1
    }

    // Generate image for a specific row
    private func generateImageForRow(row: Int, index: Int) {
        switch row {
        case 1:
            guard index < row1Images.count else { return }
            generateImageContent(for: $row1Images, at: index)
        case 2:
            guard index < row2Images.count else { return }
            generateImageContent(for: $row2Images, at: index)
        case 3:
            guard index < row3Images.count else { return }
            generateImageContent(for: $row3Images, at: index)
        default:
            break
        }
    }

    // Generate image content for a specific row's images
    private func generateImageContent(for images: Binding<[GeneratedImage]>, at index: Int) {
        guard index < images.wrappedValue.count else { return }

        // Simulate image generation with random colors
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal]
            let randomColor = colors.randomElement() ?? .gray

            let uiImage = UIImage.gradientImage(
                bounds: CGRect(x: 0, y: 0, width: 400, height: 400),
                colors: [
                    UIColor(randomColor.opacity(0.7)),
                    UIColor(randomColor)
                ]
            )

            if let uiImage = uiImage {
                images.wrappedValue[index].image = Image(uiImage: uiImage)
                images.wrappedValue[index].isLoading = false
            }
        }
    }
}

// Reusable carousel row component
struct ImageCarouselRow: View {
    @Binding var images: [GeneratedImage]
    @Binding var currentPage: Int
    let accentColor: Color
    let rowNumber: Int
    let onDismiss: () -> Void
    let onShare: (UIImage) -> Void

    var body: some View {
        VStack(spacing: 10) {
            TabView(selection: $currentPage) {
                ForEach(Array(images.enumerated()), id: \.element.id) { index, imageItem in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width * 0.6)

                        if imageItem.isLoading {
                            ProgressView()
                        } else if let image = imageItem.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.width * 0.6)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(alignment: .bottomTrailing) {
                                    // Down arrow button on bottom right
                                    Button {
                                        onDismiss()
                                    } label: {
                                        Image(systemName: "arrow.down.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(accentColor)
                                            .background(
                                                Circle()
                                                    .fill(.white)
                                                    .frame(width: 30, height: 30)
                                            )
                                    }
                                    .padding(12)
                                }
                                .contextMenu {
                                    Button {
                                        saveImageToPhotoLibrary(index: index)
                                    } label: {
                                        Label("Save to Photos", systemImage: "photo.on.rectangle")
                                    }

                                    Button {
                                        if let uiImage = convertImageToUIImage(index: index) {
                                            onShare(uiImage)
                                        }
                                    } label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                        } else {
                            Text("Row \(rowNumber) - Image \(index + 1)")
                                .foregroundColor(.gray)
                        }
                    }
                    .tag(index)
                    .onAppear {
                        // Delay the actions slightly to allow animation to complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            // Only perform special onAppear actions when this page becomes visible
                            if index == currentPage {
                                // 1. Add a new placeholder if this is the last one
                                checkAndAddNextPlaceholder(currentIndex: index)

                                // 2. If this is an empty placeholder, start generating
                                if index < images.count &&
                                   !images[index].isLoading &&
                                   images[index].image == nil {
                                    generateImage(atIndex: index)
                                }
                            }
                        }
                    }
                }
            }
            .id(images.count) // Force TabView to reinitialize when number of items changes
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: UIScreen.main.bounds.width * 0.6)
            .onChange(of: currentPage) { oldValue, newValue in
                // Delay to allow animation to complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    checkAndAddNextPlaceholder(currentIndex: newValue)
                }
            }

            // Page indicator dots - simple row with just visible dots
            HStack(spacing: 8) {
                ForEach(Array(images.indices), id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 5)
        }
    }

    // Helper methods
    private func checkAndAddNextPlaceholder(currentIndex: Int) {
        // Only add a new placeholder if we're at the last available one
        if currentIndex == images.count - 1 {
            images.append(GeneratedImage(isLoading: false, image: nil))
        }

        // If we're viewing an empty placeholder (not loading), start generating
        if currentIndex < images.count &&
           !images[currentIndex].isLoading &&
           images[currentIndex].image == nil {
            generateImage(atIndex: currentIndex)
        }
    }

    // This method sets the loading state and calls the content generation
    private func generateImage(atIndex index: Int) {
        guard index < images.count else { return }

        // Set the image to loading state
        images[index].isLoading = true

        // Delay the actual generation to allow for smooth animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generateImageContent(atIndex: index)
        }
    }

    // This method actually generates the image content
    private func generateImageContent(atIndex index: Int) {
        guard index < images.count else { return }

        // Simulate image generation with random colors
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Create a simulated generated image with a random color
            let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal]
            let randomColor = colors.randomElement() ?? .gray

            let uiImage = UIImage.gradientImage(
                bounds: CGRect(x: 0, y: 0, width: 400, height: 400),
                colors: [
                    UIColor(randomColor.opacity(0.7)),
                    UIColor(randomColor)
                ]
            )

            if let uiImage = uiImage {
                // Update the image in our array
                images[index].image = Image(uiImage: uiImage)
                images[index].isLoading = false
            }
        }
    }

    // Save image to photo library
    private func saveImageToPhotoLibrary(index: Int) {
        guard index < images.count,
              let image = images[index].image,
              let uiImage = convertImageToUIImage(index: index) else { return }

        UIImageWriteToSavedPhotosAlbum(uiImage, ImageGenerationViewWrapper.shared, #selector(ImageGenerationViewWrapper.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    // Helper to convert SwiftUI Image to UIImage
    private func convertImageToUIImage(index: Int) -> UIImage? {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal]
        let randomColor = colors[index % colors.count]

        return UIImage.gradientImage(
            bounds: CGRect(x: 0, y: 0, width: 400, height: 400),
            colors: [
                UIColor(randomColor.opacity(0.7)),
                UIColor(randomColor)
            ]
        )
    }
}

#Preview {
    ImageGenerationView()
}
