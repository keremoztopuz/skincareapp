#if DEBUG
import SwiftUI
import TipKit

enum ScreenshotScreen: String {
    case home, result, regions, recents, compare, search, guide, profile, paywall

    static var current: ScreenshotScreen? {
        UserDefaults.standard.string(forKey: "screenshotScreen").flatMap(Self.init(rawValue:))
    }
}

/// Direct routes for deterministic App Store captures. Debug-only, so none
/// of the seeded content or routing is present in the submitted binary.
struct ScreenshotRoot: View {
    // MARK: - Properties
    let screen: ScreenshotScreen
    @State private var isReady = false

    private var records: [AnalysisRecord] {
        LocalPersistenceManager.shared.fetchAnalysisRecords()
    }

    // MARK: - Body
    var body: some View {
        Group {
            if isReady {
                content
            } else {
                Color.brandBackground.ignoresSafeArea()
            }
        }
        .task {
            Tips.hideAllTipsForTesting()
            SubscriptionManager.shared.isPremium = true
            if records.isEmpty {
                MockScanSeeder.seed(into: .shared)
            }
            isReady = true
        }
    }

    @ViewBuilder
    private var content: some View {
        switch screen {
        case .home:
            MainTabView(initialTab: 0)
        case .result:
            ResultView(record: records.last, isFromRecents: true, showsInteractionTip: false)
        case .regions:
            ResultView(record: records.last, isFromRecents: true, initialConditionKey: "acne", showsInteractionTip: false)
        case .recents:
            MainTabView(initialTab: 3)
        case .compare:
            if records.count >= 2 {
                NavigationStack { CompareView(record1: records.last!, record2: records.first!) }
            }
        case .search:
            MainTabView(initialTab: 1)
        case .guide:
            CameraGuideView()
        case .profile:
            MainTabView(initialTab: 4)
        case .paywall:
            UpgradeSheetView(context: .onboarding)
        }
    }
}
#endif
