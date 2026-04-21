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
            Text("main app")
        case .splash:
            SplashView()
        }
    }
}

#Preview {
    ContentView()
}
