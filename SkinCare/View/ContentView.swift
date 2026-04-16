import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnBoarding") private var
      hasCompletedOnBoarding = false
    @AppStorage("hasCompletedProfile") private var
      hasCompletedProfile = false
    var body: some View {
        if !hasCompletedOnBoarding {
            OnBoardingView()
        } else if !hasCompletedProfile {
            ProfileSetupView()
        }
    }
}

#Preview {
    ContentView()
}
