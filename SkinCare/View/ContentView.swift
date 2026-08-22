import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: ContentViewModel
    
    var body: some View {
        switch vm.currentState {
        case .onboarding:
            OnBoardingView()
        case .disclaimer:
            DisclaimerView()
        case .profileSetup:
            ProfileSetupView()
        case .mainApp:
            MainTabView()
        case .splash:
            SplashView()
        case .loading:
            SplashView(loadingMessage: NSLocalizedString("preparing_profile", comment: ""))
        case .subscription:
            SubscriptionView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ContentViewModel())
}
