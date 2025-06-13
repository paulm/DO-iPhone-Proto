import SwiftUI

// MARK: - Experiments Framework

enum AppSection: String, CaseIterable, Identifiable {
    case todayTab = "Today Tab"
    case journalsTab = "Journals Tab"
    case promptsTab = "Prompts Tab"
    case moreTab = "More Tab"
    case journalPicker = "Journal Picker"
    case entryView = "Entry View"
    
    var id: String { rawValue }
}

enum ExperimentVariant: String, CaseIterable, Identifiable {
    case original = "Original"
    case appleSettings = "Apple Settings"
    case variant2 = "Variant 2"
    case paged = "Paged"
    
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
            return [.original, .appleSettings] // Settings-style variant
        case .todayTab:
            return [.original, .appleSettings] // Settings-style variant
        case .journalsTab:
            return [.original, .appleSettings, .variant2, .paged] // All variants
        case .journalPicker:
            return [.original] // All use compact layout now
        case .entryView:
            return [.original] // Only original for now, will expand later
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
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Experiments")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ExperimentsView()
}