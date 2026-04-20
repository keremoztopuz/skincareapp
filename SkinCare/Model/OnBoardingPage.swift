import CoreGraphics
import Foundation

struct OnBoardingPage {
    let lottieAnimation: String?
    let lottieScale: CGFloat
    let lottieOffset: CGPoint
    let lottieSpeed: CGFloat
    let lottieRepeatDelay: TimeInterval
    let icon: String
    let title: String
    let description: String

    init(lottieAnimation: String? = nil,
         lottieScale: CGFloat = 1.0,
         lottieOffset: CGPoint = .zero,
         lottieSpeed: CGFloat = 1.0,
         lottieRepeatDelay: TimeInterval = 0,
         icon: String,
         title: String,
         description: String) {
        self.lottieAnimation = lottieAnimation
        self.lottieScale = lottieScale
        self.lottieOffset = lottieOffset
        self.lottieSpeed = lottieSpeed
        self.lottieRepeatDelay = lottieRepeatDelay
        self.icon = icon
        self.title = title
        self.description = description
    }
}
