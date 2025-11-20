import SwiftUI

struct CustomSheetView: View {
    let journal: Journal?
    let sheetRegularPosition: CGFloat
    let mediumDetentHeight: CGFloat?
    let largeDetentHeight: CGFloat?
    @ObservedObject var sheetState: SheetState
    let useStandardController: Bool
    let useLargeListDates: Bool
    let showFAB: Bool
    @State private var isSheetPresented = false

    init(journal: Journal?,
         sheetRegularPosition: CGFloat,
         mediumDetentHeight: CGFloat? = nil,
         largeDetentHeight: CGFloat? = nil,
         sheetState: SheetState? = nil,
         useStandardController: Bool = true,
         useLargeListDates: Bool = false,
         showFAB: Bool = true) {
        self.journal = journal
        self.sheetRegularPosition = sheetRegularPosition
        self.mediumDetentHeight = mediumDetentHeight
        self.largeDetentHeight = largeDetentHeight
        self.sheetState = sheetState ?? SheetState()
        self.useStandardController = useStandardController
        self.useLargeListDates = useLargeListDates
        self.showFAB = showFAB
    }
    
    var body: some View {
        CustomSheetHostingController(
            journal: journal,
            sheetRegularPosition: sheetRegularPosition,
            sheetState: sheetState,
            isPresented: $isSheetPresented,
            mediumDetentHeight: mediumDetentHeight,
            largeDetentHeight: largeDetentHeight,
            useStandardController: useStandardController,
            useLargeListDates: useLargeListDates,
            showFAB: showFAB
        )
        .ignoresSafeArea()
        .onAppear {
            // Delay sheet presentation to ensure smooth animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSheetPresented = true
            }
        }
    }
}

struct CustomSheetHostingController: UIViewControllerRepresentable {
    let journal: Journal?
    let sheetRegularPosition: CGFloat
    let sheetState: SheetState
    @Binding var isPresented: Bool
    let mediumDetentHeight: CGFloat?
    let largeDetentHeight: CGFloat?
    let useStandardController: Bool
    let useLargeListDates: Bool
    let showFAB: Bool

    func makeUIViewController(context: Context) -> CustomSheetParentViewController {
        return CustomSheetParentViewController(
            journal: journal,
            sheetRegularPosition: sheetRegularPosition,
            sheetState: sheetState,
            isPresented: $isPresented,
            mediumDetentHeight: mediumDetentHeight,
            largeDetentHeight: largeDetentHeight,
            useStandardController: useStandardController,
            useLargeListDates: useLargeListDates,
            showFAB: showFAB
        )
    }
    
    func updateUIViewController(_ uiViewController: CustomSheetParentViewController, context: Context) {
        uiViewController.updatePresentationState(isPresented)
    }
}

// Parent view controller that hosts the sheet
class CustomSheetParentViewController: UIViewController {
    private var sheetViewController: CustomSheetViewController?
    private let journal: Journal?
    private let sheetRegularPosition: CGFloat
    private let sheetState: SheetState
    private var isPresented: Binding<Bool>
    private let mediumDetentHeight: CGFloat?
    private let largeDetentHeight: CGFloat?
    private let useStandardController: Bool
    private let useLargeListDates: Bool
    private let showFAB: Bool

    init(journal: Journal?,
         sheetRegularPosition: CGFloat,
         sheetState: SheetState,
         isPresented: Binding<Bool>,
         mediumDetentHeight: CGFloat? = nil,
         largeDetentHeight: CGFloat? = nil,
         useStandardController: Bool = true,
         useLargeListDates: Bool = false,
         showFAB: Bool = true) {
        self.journal = journal
        self.sheetRegularPosition = sheetRegularPosition
        self.sheetState = sheetState
        self.isPresented = isPresented
        self.mediumDetentHeight = mediumDetentHeight
        self.largeDetentHeight = largeDetentHeight
        self.useStandardController = useStandardController
        self.useLargeListDates = useLargeListDates
        self.showFAB = showFAB
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make background transparent
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
    }
    
    func updatePresentationState(_ presented: Bool) {
        if presented && sheetViewController == nil {
            presentCustomSheet()
        } else if !presented && sheetViewController != nil {
            dismissCustomSheet()
        }
    }
    
    private func presentCustomSheet() {
        // Create and configure the sheet view controller
        let sheet = CustomSheetViewController(
            journal: journal,
            sheetRegularPosition: sheetRegularPosition,
            sheetState: sheetState,
            mediumDetentHeight: mediumDetentHeight,
            largeDetentHeight: largeDetentHeight,
            useStandardController: useStandardController,
            useLargeListDates: useLargeListDates,
            showFAB: showFAB
        )
        
        sheetViewController = sheet
        
        // Add as child view controller
        addChild(sheet)
        view.addSubview(sheet.view)
        sheet.didMove(toParent: self)
        
        // Configure initial sheet position
        sheet.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sheet.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheet.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Animate sheet in
        sheet.animateIn()
    }
    
    private func dismissCustomSheet() {
        guard let sheet = sheetViewController else { return }
        
        sheet.animateOut { [weak self] in
            sheet.willMove(toParent: nil)
            sheet.view.removeFromSuperview()
            sheet.removeFromParent()
            self?.sheetViewController = nil
        }
    }
}