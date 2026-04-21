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
        "Get ready to shine!",
        "Your skin is your home.",
        "Drinking 2 liters of water keeps your skin hydrated.",
        "Don't forget to moisturize in your night routine.",
        "Vitamin C serum helps even out your skin tone."
    ]

    @State private var currentTip: String = ""
    @State private var logoScale: CGFloat = 0
    @State private var titleScale: CGFloat = 0
    @State private var tipScale: CGFloat = 0
    @State private var isPulsing = false

    var body: some View {
        GeometryReader { geo in
            let outerSize = geo.size.width * 0.42
            let innerSize = outerSize * 0.75

            ZStack {
                Color(red: 1.0, green: 0.97, blue: 0.97)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    // Logo
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.87, blue: 0.87))
                            .frame(width: outerSize, height: outerSize)
                            .scaleEffect(isPulsing ? 1.12 : 1.0)
                            .animation(
                                .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                                value: isPulsing
                            )

                        Circle()
                            .fill(Color(red: 0.47, green: 0.11, blue: 0.17))
                            .frame(width: innerSize, height: innerSize)

                        // Icon
                        Image(systemName: "leaf.fill")
                            .font(.system(size: innerSize * 0.4))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)

                    // App name
                    Text("SkinCareAI")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.47, green: 0.11, blue: 0.17))
                        .padding(.top, 12)
                        .scaleEffect(titleScale)
                    
                    Text("Your personal AI assisted skincare expert")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 1)
                        .padding(.horizontal)
                        .scaleEffect(titleScale)
                        .padding(.bottom, 20)

                    Spacer()

                    // Tip
                    Text(currentTip)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .scaleEffect(tipScale)
                        .padding(.bottom, 50)
                }
                .frame(width: geo.size.width)
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
