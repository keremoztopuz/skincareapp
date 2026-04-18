import SwiftUI

// MARK: CONTENT VIEW OPTIMIZATION

// FOR NOW, JUST RESETS THE PAGE ON EVERY BUILD.

struct ContentView: View {
    @AppStorage("hasCompletedOnBoarding") private var hasCompletedOnBoarding = false
    @AppStorage("hasCompletedProfile") private var hasCompletedProfile = false

    var body: some View {
        if !hasCompletedOnBoarding {
            OnBoardingView()
        } else if !hasCompletedProfile {
            ProfileSetupView()
        } else {
            Text("Main App")
        }
    }
}

#Preview {
    ContentView()
}
