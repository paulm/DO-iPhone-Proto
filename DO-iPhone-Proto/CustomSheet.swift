import SwiftUI
import Combine

struct CustomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let regularPosition: CGFloat
    let sheetState: SheetState?
    @ViewBuilder let content: Content
    @State private var currentDetent: SheetDetent = .regular
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var sheetHeight: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    @State private var isScrollViewAtTop = true
    @State private var scrollViewProxy: ScrollViewProxy?
    @State private var isHandlingSheetDrag = false
    
    // For continuous gesture handling
    @State private var dragVelocity: CGFloat = 0
    @State private var lastDragTime = Date()
    
    init(isPresented: Binding<Bool>, regularPosition: CGFloat = 250, sheetState: SheetState? = nil, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.regularPosition = regularPosition
        self.sheetState = sheetState
        self.content = content()
    }
    
    enum SheetDetent {
        case regular
        case expanded
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            if isPresented {
                VStack(spacing: 0) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(UIColor.tertiaryLabel))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isHandlingSheetDrag {
                                        isHandlingSheetDrag = true
                                        isDragging = true
                                    }
                                    handleDragChanged(value: value, in: geometry)
                                }
                                .onEnded { value in
                                    handleDragEnded(value: value, in: geometry)
                                    isHandlingSheetDrag = false
                                }
                        )
                    
                    // Content with scroll detection
                    GeometryReader { scrollGeometry in
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                VStack(spacing: 0) {
                                    // Invisible anchor at top
                                    Color.clear
                                        .frame(height: 1)
                                        .id("top")
                                    
                                    // Track scroll position
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self,
                                                       value: geo.frame(in: .named("scrollView")).minY)
                                    }
                                    .frame(height: 0)
                                    
                                    content
                                        .background(
                                            GeometryReader { contentGeometry in
                                                Color.clear
                                                    .onAppear {
                                                        contentHeight = contentGeometry.size.height
                                                    }
                                                    .onChange(of: contentGeometry.size.height) { _, newHeight in
                                                        contentHeight = newHeight
                                                    }
                                            }
                                        )
                                }
                            }
                            .coordinateSpace(name: "scrollView")
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                scrollOffset = value
                                // Consider at top if scroll offset is close to 0
                                isScrollViewAtTop = value >= -1
                            }
                            .scrollDisabled(currentDetent == .regular || isHandlingSheetDrag)
                            .onAppear {
                                self.scrollViewProxy = scrollProxy
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        // Invisible drag area at the top when expanded and at scroll top
                        Group {
                            if currentDetent == .expanded && isScrollViewAtTop {
                                VStack {
                                    Color.clear
                                        .frame(height: 40)
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    if value.translation.height > 5 {
                                                        handleContentDragChanged(value: value, in: geometry)
                                                    }
                                                }
                                                .onEnded { value in
                                                    handleContentDragEnded(value: value, in: geometry)
                                                }
                                        )
                                    Spacer()
                                }
                            }
                        }
                    )
                }
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(radius: 20)
                .offset(y: sheetOffset(in: geometry) + dragOffset)
                .background(
                    GeometryReader { sheetGeometry in
                        Color.clear
                            .onAppear {
                                sheetHeight = sheetGeometry.size.height
                            }
                            .onChange(of: sheetGeometry.size.height) { _, newHeight in
                                sheetHeight = newHeight
                            }
                    }
                )
                .overlay(
                    // Invisible drag area for expanding from regular position
                    Group {
                        if currentDetent == .regular {
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if value.translation.height < -5 {
                                                if !isHandlingSheetDrag {
                                                    isHandlingSheetDrag = true
                                                    isDragging = true
                                                }
                                                handleDragChanged(value: value, in: geometry)
                                            }
                                        }
                                        .onEnded { value in
                                            if isHandlingSheetDrag {
                                                handleDragEnded(value: value, in: geometry)
                                                isHandlingSheetDrag = false
                                            }
                                        }
                                )
                        }
                    }
                )
                .animation(isDragging ? nil : .interactiveSpring(response: 0.4, dampingFraction: 0.8), value: currentDetent)
                .animation(isDragging ? nil : .interactiveSpring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                .transition(.move(edge: .bottom))
                .zIndex(0)
            }
        }
        .ignoresSafeArea()
    }
    
    private func sheetOffset(in geometry: GeometryProxy) -> CGFloat {
        switch currentDetent {
        case .regular:
            return 320 // 320pt from top
        case .expanded:
            return 100 // 100pt from top
        }
    }
    
    private func handleDragChanged(value: DragGesture.Value, in geometry: GeometryProxy) {
        isDragging = true
        
        // Calculate velocity
        let currentTime = Date()
        let timeDiff = currentTime.timeIntervalSince(lastDragTime)
        if timeDiff > 0 {
            dragVelocity = (value.translation.height - lastDragValue) / CGFloat(timeDiff)
        }
        lastDragValue = value.translation.height
        lastDragTime = currentTime
        
        // Apply drag offset with resistance at bounds
        let proposedOffset = value.translation.height
        let currentPosition = sheetOffset(in: geometry) + proposedOffset
        
        // Add resistance when dragging beyond bounds
        if currentPosition < 100 { // Beyond expanded position
            let overscroll = 100 - currentPosition
            dragOffset = proposedOffset + (overscroll * 0.7) // Rubber band effect
        } else if currentPosition > 320 && currentDetent == .regular { // Beyond regular position
            let overscroll = currentPosition - 320
            dragOffset = proposedOffset - (overscroll * 0.7) // Rubber band effect
        } else {
            dragOffset = proposedOffset
        }
    }
    
    private func handleDragEnded(value: DragGesture.Value, in geometry: GeometryProxy) {
        isDragging = false
        
        let translation = value.translation.height
        let velocity = dragVelocity
        
        // Determine target detent based on position, velocity, and thresholds
        let expandThreshold: CGFloat = 50
        let velocityThreshold: CGFloat = 500
        
        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
            if currentDetent == .regular {
                // Check if we should expand
                if translation < -expandThreshold || velocity < -velocityThreshold {
                    currentDetent = .expanded
                    sheetState?.isExpanded = true
                }
            } else {
                // Check if we should collapse
                if translation > expandThreshold || velocity > velocityThreshold {
                    currentDetent = .regular
                    sheetState?.isExpanded = false
                }
            }
            
            dragOffset = 0
            dragVelocity = 0
        }
    }
    
    private func handleContentDragChanged(value: DragGesture.Value, in geometry: GeometryProxy) {
        if !isHandlingSheetDrag {
            isHandlingSheetDrag = true
            isDragging = true
        }
        handleDragChanged(value: value, in: geometry)
    }
    
    private func handleContentDragEnded(value: DragGesture.Value, in geometry: GeometryProxy) {
        if isHandlingSheetDrag {
            handleDragEnded(value: value, in: geometry)
            isHandlingSheetDrag = false
        }
    }
}

// Custom sheet modifier
struct CustomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let regularPosition: CGFloat
    let sheetState: SheetState?
    @ViewBuilder let sheetContent: () -> SheetContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            CustomSheet(isPresented: $isPresented, regularPosition: regularPosition, sheetState: sheetState) {
                sheetContent()
            }
        }
    }
}

// Preference key for scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Extension to make it easier to use
extension View {
    func customSheet<Content: View>(
        isPresented: Binding<Bool>,
        regularPosition: CGFloat = 250,
        sheetState: SheetState? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(CustomSheetModifier(isPresented: isPresented, regularPosition: regularPosition, sheetState: sheetState, sheetContent: content))
    }
}