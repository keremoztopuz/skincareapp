import Foundation
internal import Combine

class OnBoardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0

    func completeOnBoarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnBoarding")
    }
}
