//
//  OnBoardingView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 29.03.2026.
//

import SwiftUI

struct OnBoardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnBoardingPageView: View {
    let page: OnBoardingPage

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: page.icon)
                .font(.system(size: 80))
            Text(page.title)
                .font(.largeTitle).bold()
            Text(page.description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
struct OnBoardingView: View {
    @StateObject private var vm = OnBoardingViewModel()
    @AppStorage("hasCompletedOnBoarding") private var hasCompleted = false
    
    let pages: [OnBoardingPage] = [
        OnBoardingPage(
            icon: "sparkles",
            title: "AI Powered Skin Analysis",
            description: "Analyze your skin in seconds with your camera."
        ),
        OnBoardingPage(
            icon: "lock.shield",
            title: "Data Stays On Device",
            description: "Your face data never leaves your device."
        ),
        OnBoardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "Save every analysis and see how you improve over time."
        )
    ]
    
    var body: some View{
        VStack {
            TabView(selection: $vm.currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnBoardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            Button(vm.currentPage == pages.count - 1 ? "Başla" : "İleri") {
                if vm.currentPage < pages.count - 1 {
                    vm.currentPage += 1
                } else {
                    vm.completeOnBoarding()
                    hasCompleted = true
                }
            }
            
        }
    }
    
}

#Preview {
    OnBoardingView()
}
