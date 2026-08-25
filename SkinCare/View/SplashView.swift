//
//  SplashView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 21.04.2026.
//

import SwiftUI

struct SplashView: View {
    // tips
    private let tips: [String] = [
        AppStrings.splashTipShine,
        AppStrings.splashTipSkinHome,
        AppStrings.splashTipWater,
        AppStrings.splashTipMoisturize,
        AppStrings.splashTipVitaminC
    ]
    
    var loadingMessage: String? = nil

    @State private var currentTip: String = ""
    @State private var isPulsing = false
    @State private var logoScale: CGFloat = 0
    @State private var titleScale: CGFloat = 0
    @State private var tipScale: CGFloat = 0

    var body: some View {
        ZStack {
            // Outside the GeometryReader so the fill always reaches the status bar.
            Color.brandBackground
                .ignoresSafeArea()

            GeometryReader { geo in
                let outerSize = geo.size.width * 0.42
                let innerSize = outerSize * 0.75

                ZStack {

                VStack {
                    Spacer()

                    // Logo — the original splash sizing: nested circles with
                    // the template logo drawn at its full 200pt size.
                    ZStack {
                        Circle()
                            .fill(Color.brandBlush)
                            .frame(width: outerSize, height: outerSize)
                            .scaleEffect(isPulsing ? 1.12 : 1.0)
                            .animation(
                                .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                                value: isPulsing
                            )

                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: innerSize, height: innerSize)

                        Image("AppLogo")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)


                    // App name
                    Text("Skinner")
                        .font(.scaled(size: 28, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .padding(.top, 12)
                        .scaleEffect(titleScale)
                    
                    Text(NSLocalizedString("your_personal_expert", comment: ""))
                        .font(.scaled(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 1)
                        .padding(.horizontal)
                        .scaleEffect(titleScale)
                        .padding(.bottom, 20)

                    Spacer()
                    if let message = loadingMessage {
                        Text(message)
                            .font(.scaled(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.bottom, 32)
                            .scaleEffect(titleScale)
                    }
                    // Tip
                    Text(currentTip)
                        .font(.scaled(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .scaleEffect(tipScale)
                        .padding(.bottom, 50)
                }
                .frame(width: geo.size.width)
            }
            }
            .onAppear {
                currentTip = tips.randomElement() ?? ""
                isPulsing = true

                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    logoScale = 1.0
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.5)) {
                    titleScale = 1.0
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(1.0)) {
                    tipScale = 1.0
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
