//
//  OnBoardingView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 29.03.2026.
//

import SwiftUI

// MARK: - Data Model
struct OnBoardingPage {
    let icon: String
    let title: String
    let description: String
}

// MARK: - Single Slide View
struct OnBoardingPageView: View {
    let page: OnBoardingPage

    var body: some View {
        GeometryReader { geo in
            let outerSize = geo.size.width * 0.42
            let innerSize = outerSize * 0.75

            VStack(spacing: 24) {
                Spacer()

                // icons
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.87, blue: 0.87))
                        .frame(width: outerSize, height: outerSize)
                    Circle()
                        .fill(Color(red: 0.47, green: 0.11, blue: 0.17))
                        .frame(width: innerSize, height: innerSize)
                    Image(systemName: page.icon)
                        .font(.system(size: outerSize * 0.30))
                        .foregroundColor(.white)
                }

                // title
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                // description
                Text(page.description)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .frame(width: geo.size.width)
        }
    }
}

// MARK: - Main Onboarding View
struct OnBoardingView: View {
    @StateObject private var vm = OnBoardingViewModel()
    @AppStorage("hasCompletedOnBoarding") private var hasCompleted = false

    let pages: [OnBoardingPage] = [
        OnBoardingPage(
            icon: "sparkle",
            title: "Welcome to SkinCare AI",
            description: "Your personal dermatological assistant powered by advanced AI technology."
        ),
        OnBoardingPage(
            icon: "camera",
            title: "AI-Powered Skin Analysis",
            description: "Analyze your skin in seconds with your camera. Get instant insights."
        ),
        OnBoardingPage(
            icon: "lock.shield",
            title: "Data Stays On Device",
            description: "Your face data never leaves your device. We prioritize your privacy."
        ),
        OnBoardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "Save every analysis and see how you improve over time."
        )
    ]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // background
            Color(red: 1.0, green: 0.97, blue: 0.97).ignoresSafeArea()

            VStack(spacing: 0) {
                // slide pages
                TabView(selection: $vm.currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnBoardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // page dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(vm.currentPage == index
                                  ? Color(red: 0.47, green: 0.11, blue: 0.17)
                                  : Color.gray.opacity(0.3))
                            .frame(width: vm.currentPage == index ? 24 : 8, height: 8)
                            .animation(.easeInOut, value: vm.currentPage)
                    }
                }
                .padding(.bottom, 24)

                // buttons
                HStack(spacing: 12) {
                    // back button (hidden on first page)
                    if vm.currentPage > 0 {
                        Button(action: { vm.currentPage -= 1 }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .foregroundColor(Color(red: 0.47, green: 0.11, blue: 0.17))
                            .font(.system(size: 18, weight: .semibold))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        }
                    }

                    // next 
                    Button(action: {
                        if vm.currentPage < pages.count - 1 {
                            vm.currentPage += 1
                        } else {
                            vm.completeOnBoarding()
                            hasCompleted = true
                        }
                    }) {
                        HStack {
                            Text(vm.currentPage == pages.count - 1 ? "Get Started" : "Next")
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0.47, green: 0.11, blue: 0.17))
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }

            // Skip button (hidden on last page)
            if vm.currentPage < pages.count - 1 {
                Button("Skip") {
                    vm.completeOnBoarding()
                    hasCompleted = true
                }
                .foregroundColor(.gray)
                .padding(.trailing, 24)
                .padding(.top, 16)
            }
        }
    }
}

#Preview {
    OnBoardingView()
}
