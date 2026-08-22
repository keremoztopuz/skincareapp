import Foundation
import SwiftUI
internal import Combine

class OnBoardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    
    let pages: [OnBoardingPage] = [
         OnBoardingPage(
             lottieAnimation: "AI Star loader UI",
             lottieOffset: CGPoint(x: 5, y: 0),
             icon: "viewfinder",
             title: NSLocalizedString("onboarding_title_1", comment: ""),
             description: NSLocalizedString("onboarding_desc_1", comment: "")
         ),
         OnBoardingPage(
             lottieAnimation: "Take Photo",
             lottieScale: 1.5,
             lottieOffset: CGPoint(x: -1, y: 0),
             icon: "camera",
             title: NSLocalizedString("onboarding_title_2", comment: ""),
             description: NSLocalizedString("onboarding_desc_2", comment: "")
         ),
         OnBoardingPage(
             lottieAnimation: "FaceID",
             lottieScale: 0.7,
             icon: "lock.shield",
             title: NSLocalizedString("onboarding_title_3", comment: ""),
             description: NSLocalizedString("onboarding_desc_3", comment: "")
         ),
         OnBoardingPage(
             lottieAnimation: "line graph",
             lottieSpeed: 5.0,
             lottieRepeatDelay: 1.0,
             icon: "chart.line.uptrend.xyaxis",
             title: NSLocalizedString("onboarding_title_4", comment: ""),
             description: NSLocalizedString("onboarding_desc_4", comment: "")
         )
     ]

}
