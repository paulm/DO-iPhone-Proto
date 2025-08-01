import UIKit
import SwiftUI

class CustomSheetViewController: UIViewController {
    // MARK: - Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let grabberView = UIView()
    private let contentHostingController: UIHostingController<AnyView>
    
    // Constraints for sheet positioning
    private var heightConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    // Detent positions
    private let mediumDetentRatio: CGFloat = 0.5  // 50% of screen height
    private let largeDetentRatio: CGFloat = 0.9   // 90% of screen height
    
    private var mediumDetentHeight: CGFloat {
        return UIScreen.main.bounds.height * mediumDetentRatio
    }
    
    private var largeDetentHeight: CGFloat {
        return UIScreen.main.bounds.height * largeDetentRatio
    }
    
    // Current state
    private var currentDetent: Detent = .medium
    private var isAnimating = false
    
    // Gesture recognizers
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    // Property animators for smooth transitions
    private var currentAnimator: UIViewPropertyAnimator?
    
    // Tracking
    private var initialHeight: CGFloat = 0
    private var scrollObservation: NSKeyValueObservation?
    private var isPanningSheet = false
    private var initialScrollOffset: CGFloat = 0
    private var hasReachedLargeDetent = false
    
    // References
    private let journal: Journal?
    private let sheetRegularPosition: CGFloat
    private let sheetState: SheetState
    
    enum Detent {
        case medium
        case large
    }
    
    // MARK: - Initialization
    
    init(journal: Journal?, sheetRegularPosition: CGFloat, sheetState: SheetState) {
        self.journal = journal
        self.sheetRegularPosition = sheetRegularPosition
        self.sheetState = sheetState
        
        // Create the SwiftUI content
        let sheetContent = PagedJournalSheetContent(
            journal: journal ?? Journal(name: "Default", color: .blue, entryCount: 0),
            sheetState: sheetState,
            sheetRegularPosition: sheetRegularPosition,
            showFAB: false // Disable FAB in sheet content
        )
        
        self.contentHostingController = UIHostingController(rootView: AnyView(sheetContent))
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScrollView()
        setupGrabber()
        setupGestures()
        setupContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Initial position is set by animateIn()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        // Add rounded corners
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        
        // Create height constraint with initial value
        heightConstraint = view.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
    }
    
    private func setupGrabber() {
        grabberView.backgroundColor = UIColor.systemGray3
        grabberView.layer.cornerRadius = 2.5
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(grabberView)
        
        NSLayoutConstraint.activate([
            grabberView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            grabberView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 36),
            grabberView.heightAnchor.constraint(equalToConstant: 5)
        ])
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20), // Space for grabber
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupContent() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Add SwiftUI content
        addChild(contentHostingController)
        contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentHostingController.view)
        contentHostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            contentHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentHostingController.view.heightAnchor.constraint(equalToConstant: 1000) // Content height
        ])
    }
    
    private func setupGestures() {
        // Pan gesture for dragging the sheet
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Animation Methods
    
    func animateIn() {
        // Start from below the screen
        heightConstraint.constant = 0
        view.layoutIfNeeded()
        
        // Animate to medium detent
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.heightConstraint.constant = self.mediumDetentHeight
            self.view.superview?.layoutIfNeeded()
        } completion: { _ in
            self.currentDetent = .medium
            self.sheetState.isExpanded = false
        }
    }
    
    func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.heightConstraint.constant = 0
            self.view.superview?.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }
    
    // MARK: - Gesture Handling
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            // Cancel any ongoing animation
            currentAnimator?.stopAnimation(true)
            initialHeight = heightConstraint.constant
            initialScrollOffset = scrollView.contentOffset.y
            isPanningSheet = true
            hasReachedLargeDetent = false
            
            // Always disable scrolling during sheet pan
            scrollView.isScrollEnabled = false
            
        case .changed:
            let dragDistance = -translation.y // Positive when dragging up
            
            if !hasReachedLargeDetent {
                // Phase 1: Expanding the sheet
                let newHeight = initialHeight + dragDistance
                
                if newHeight >= largeDetentHeight {
                    // We've reached large detent
                    heightConstraint.constant = largeDetentHeight
                    hasReachedLargeDetent = true
                    currentDetent = .large
                    sheetState.isExpanded = true
                    
                    // Calculate excess drag beyond large detent
                    let excessDrag = newHeight - largeDetentHeight
                    if excessDrag > 0 {
                        // Apply excess as scroll offset
                        scrollView.contentOffset = CGPoint(x: 0, y: excessDrag)
                    }
                } else {
                    // Still expanding
                    heightConstraint.constant = max(newHeight, 100) // Min height
                    scrollView.contentOffset = CGPoint(x: 0, y: 0) // Keep content at top
                }
            } else {
                // Phase 2: We're at large detent, now handle scrolling
                let totalDrag = dragDistance
                let dragToReachLarge = largeDetentHeight - initialHeight
                let scrollAmount = totalDrag - dragToReachLarge
                
                if scrollAmount > 0 {
                    // Continue scrolling content
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollAmount)
                } else {
                    // Dragging back down - collapse sheet
                    let newHeight = largeDetentHeight + scrollAmount
                    heightConstraint.constant = max(newHeight, 100)
                    scrollView.contentOffset = CGPoint(x: 0, y: 0)
                    
                    if newHeight < largeDetentHeight {
                        hasReachedLargeDetent = false
                        sheetState.isExpanded = false
                    }
                }
            }
            
        case .ended, .cancelled:
            isPanningSheet = false
            
            let currentHeight = heightConstraint.constant
            let finalScrollOffset = scrollView.contentOffset.y
            
            // Determine final state
            if hasReachedLargeDetent && finalScrollOffset > 0 {
                // We're at large detent with scrolled content - stay there
                scrollView.isScrollEnabled = true
                currentDetent = .large
                sheetState.isExpanded = true
            } else {
                // Determine target detent based on height and velocity
                let targetDetent: Detent
                
                if velocity.y < -500 && currentHeight < largeDetentHeight {
                    targetDetent = .large
                } else if velocity.y > 500 && currentHeight > mediumDetentHeight {
                    targetDetent = .medium
                } else {
                    let distanceToMedium = abs(currentHeight - mediumDetentHeight)
                    let distanceToLarge = abs(currentHeight - largeDetentHeight)
                    targetDetent = distanceToMedium < distanceToLarge ? .medium : .large
                }
                
                // Animate to target detent
                animateToDetent(targetDetent)
                
                // Reset scroll position if not at large detent
                if targetDetent != .large || finalScrollOffset <= 0 {
                    scrollView.setContentOffset(.zero, animated: true)
                }
            }
            
            // Re-enable scrolling after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.scrollView.isScrollEnabled = true
            }
            
        default:
            break
        }
    }
    
    // MARK: - Height Management
    
    private func setSheetHeight(_ height: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.heightConstraint.constant = height
                self.view.superview?.layoutIfNeeded()
            }
        } else {
            heightConstraint.constant = height
        }
    }
    
    // MARK: - Animation
    
    private func animateToDetent(_ detent: Detent) {
        guard currentDetent != detent || !isAnimating else { return }
        
        isAnimating = true
        currentDetent = detent
        sheetState.isExpanded = (detent == .large)
        
        let targetHeight = detent == .medium ? mediumDetentHeight : largeDetentHeight
        
        // Cancel any existing animation
        currentAnimator?.stopAnimation(true)
        
        // Create spring animation
        currentAnimator = UIViewPropertyAnimator(
            duration: 0.4,
            timingParameters: UISpringTimingParameters(
                dampingRatio: 0.85,
                initialVelocity: CGVector(dx: 0, dy: 0)
            )
        )
        
        currentAnimator?.addAnimations { [weak self] in
            self?.heightConstraint.constant = targetHeight
            self?.view.superview?.layoutIfNeeded()
        }
        
        currentAnimator?.addCompletion { [weak self] _ in
            self?.isAnimating = false
            self?.currentAnimator = nil
            
            // Re-enable scroll if it was disabled
            self?.scrollView.isScrollEnabled = true
        }
        
        currentAnimator?.startAnimation()
    }
}

// MARK: - UIScrollViewDelegate

extension CustomSheetViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // If we're panning the sheet, keep scroll at top
        if isPanningSheet {
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            return
        }
        
        let offset = scrollView.contentOffset.y
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
        
        // Only handle scroll-to-expand when at top of content
        guard offset <= 0 else {
            scrollView.bounces = true
            return
        }
        
        // At medium detent, we want the pan gesture to handle upward drags
        if currentDetent == .medium && velocity.y < 0 && offset <= 0 {
            // Let the pan gesture handle expansion
            scrollView.bounces = false
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            return
        }
        
        // Disable bounce at top to handle other cases
        scrollView.bounces = false
        
        // Check for pull-to-collapse (scrolling down at top)
        if velocity.y > 300 && currentDetent == .large && !isAnimating {
            scrollView.isScrollEnabled = false
            animateToDetent(.medium)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Re-enable scrolling if it was disabled
        if !scrollView.isScrollEnabled {
            scrollView.isScrollEnabled = true
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension CustomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            let location = gestureRecognizer.location(in: view)
            let velocity = panGestureRecognizer.velocity(in: view)
            
            // Always allow dragging from grabber area
            if location.y < 40 {
                return true
            }
            
            // When scroll view is at top
            if scrollView.contentOffset.y <= 0 {
                // At large detent, only allow downward drags
                if currentDetent == .large && velocity.y > 0 {
                    return true
                }
                // At medium detent, allow both up and down
                if currentDetent == .medium {
                    return true
                }
            }
        }
        
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow simultaneous recognition for smooth handoff between sheet drag and scroll
        if gestureRecognizer == panGestureRecognizer && otherGestureRecognizer == scrollView.panGestureRecognizer {
            return scrollView.contentOffset.y <= 0
        }
        return false
    }
}