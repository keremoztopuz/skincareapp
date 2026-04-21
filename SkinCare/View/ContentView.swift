import SwiftUI

// MARK: CONTENT VIEW OPTIMIZATION

// FOR NOW, JUST RESETS THE PAGE ON EVERY BUILD.

struct ContentView: View {
    @StateObject private var vm = ContentViewModel()
    
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
            SplashView(loadingMessage: "Saving your data on your device...")
        }
    }
}

#Preview {
    ContentView()
}
