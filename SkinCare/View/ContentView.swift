import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: ContentViewModel
    
    var body: some View {
        switch vm.currentState {
        case .onboarding:
            OnBoardingView()
        case .profileSetup:
            ProfileSetupView()
        case .mainApp:
            MainTabView()
        case .splash:
            SplashView()
        case .loading:
            SplashView(loadingMessage: NSLocalizedString("preparing_profile", comment: ""))
        case .subscription:
            // The same paywall the rest of the app shows, as a flow step: it
            // advances the state machine instead of dismissing, because
            // nothing presented it.
            UpgradeSheetView(context: .onboarding) { isPremium in
                vm.completePurchaseStep(isPremium: isPremium)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ContentViewModel())
}
