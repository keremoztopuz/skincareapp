import Foundation
import SwiftUI
internal import Combine

class OnBoardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    
    let pages: [OnBoardingPage] = [
         OnBoardingPage(
             lottieAnimation: "AI Star loader UI",
             lottieOffset: CGPoint(x: 5, y: 0),
             icon: "sparkle",
             title: "Welcome to SkinCare AI",
             description: "Your personal dermatological assistant powered by advanced AI technology."
         ),
         OnBoardingPage(
             lottieAnimation: "Take Photo",
             lottieScale: 1.5,
             lottieOffset: CGPoint(x: -1, y: 0),
             icon: "camera",
             title: "AI-Powered Skin Analysis",
             description: "Analyze your skin in seconds with your camera. Get instant insights."
         ),
         OnBoardingPage(
             lottieAnimation: "FaceID",
             lottieScale: 0.7,
             icon: "lock.shield",
             title: "Data Stays On Device",
             description: "Your face data never leaves your device. We prioritize your privacy."
         ),
         OnBoardingPage(
             lottieAnimation: "line graph",
             lottieSpeed: 5.0,
             lottieRepeatDelay: 1.0,
             icon: "chart.line.uptrend.xyaxis",
             title: "Track Your Progress",
             description: "Save every analysis and see how you improve over time."
         )
     ]

}
