import SwiftUI

// MARK: - Experiments Framework

enum AppSection: String, CaseIterable, Identifiable {
    case todayTab = "Today Tab"
    case journalsTab = "Journals Tab"
    case promptsTab = "Prompts Tab"
    case moreTab = "More Tab"
    case journalPicker = "Journal Picker"
    case entryView = "Entry View"
    case momentsModal = "Moments Modal"
    
    var id: String { rawValue }
}

enum ExperimentVariant: String, CaseIterable, Identifiable {
    case original = "Original"
    case appleSettings = "Apple Settings"
    case variant2 = "Variant 2"
    case paged = "Paged"
    case v1i1 = "v1i1"
    case v1i2 = "v1i2"
    case grid = "Grid"
    
    var id: String { rawValue }
}

@Observable
class ExperimentsManager {
    private var variants: [AppSection: ExperimentVariant] = [:]
    
    static let shared = ExperimentsManager()
    
    private init() {
        // Initialize all sections to original variant
        for section in AppSection.allCases {
            variants[section] = .original
        }
        
        // Set Today tab to use v1i2 as default
        variants[.todayTab] = .v1i2
        
        // Set Moments modal to use grid as default
        variants[.momentsModal] = .grid
        
        // Set Journals tab to use paged as default
        variants[.journalsTab] = .paged
    }
    
    func variant(for section: AppSection) -> ExperimentVariant {
        return variants[section] ?? .original
    }
    
    func setVariant(_ variant: ExperimentVariant, for section: AppSection) {
        variants[section] = variant
    }
    
    // Global variant switching
    func setGlobalVariant(_ variant: ExperimentVariant) {
        for section in AppSection.allCases {
            let availableVariants = availableVariants(for: section)
            if availableVariants.contains(variant) {
                variants[section] = variant
            }
        }
    }
    
    func getGlobalVariant() -> ExperimentVariant? {
        // Check if all sections that have multiple variants are set to the same variant
        let sectionsWithVariants = AppSection.allCases.filter { availableVariants(for: $0).count > 1 }
        let uniqueVariants = Set(sectionsWithVariants.map { variant(for: $0) })
        
        return uniqueVariants.count == 1 ? uniqueVariants.first : nil
    }
    
    // Get available variants for a section (can be customized per section)
    func availableVariants(for section: AppSection) -> [ExperimentVariant] {
        switch section {
        case .moreTab:
            return [.original, .appleSettings] // Settings-style variant
        case .promptsTab:
            return [.original] // Only original variant
        case .todayTab:
            return [.v1i2] // Only v1i2 variant
        case .journalsTab:
            return [.paged] // Only paged variant
        case .journalPicker:
            return [.original] // All use compact layout now
        case .entryView:
            return [.original] // Only original for now, will expand later
        case .momentsModal:
            return [.original, .grid] // List and Grid variants
        }
    }
}

// MARK: - Experiments Settings View

struct ExperimentsView: View {
    private var experimentsManager = ExperimentsManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Test different layouts and designs for various sections of the app. These are experimental features that may change or be removed.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                
                // Global Controls Section
                Section("Global Controls") {
                    Text("Apply the same variant to all sections at once")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    
                    ForEach([ExperimentVariant.original, ExperimentVariant.appleSettings], id: \.self) { variant in
                        HStack {
                            Text(variant.rawValue)
                                .font(.body)
                            
                            Spacer()
                            
                            if experimentsManager.getGlobalVariant() == variant {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(hex: "44C0FF"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            experimentsManager.setGlobalVariant(variant)
                        }
                    }
                }
                
                // Individual Section Controls
                Section("Individual Section Controls") {
                    ForEach(AppSection.allCases) { section in
                        ExperimentSectionRow(section: section, experimentsManager: experimentsManager)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Experiments")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ExperimentSectionRow: View {
    let section: AppSection
    let experimentsManager: ExperimentsManager
    
    var body: some View {
        let availableVariants = experimentsManager.availableVariants(for: section)
        
        if availableVariants.count > 1 {
            DisclosureGroup(section.rawValue) {
                ForEach(availableVariants) { variant in
                    HStack {
                        Text(variant.rawValue)
                            .font(.body)
                        
                        Spacer()
                        
                        if experimentsManager.variant(for: section) == variant {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(hex: "44C0FF"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        experimentsManager.setVariant(variant, for: section)
                    }
                }
            }
        }
    }
}

#Preview {
    ExperimentsView()
}