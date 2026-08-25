//
//  OnBoardingView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 29.03.2026.
//
// THIS FILE IS FOR ONBOARDING PAGES. TO INTRODUCE THE APP FOR USER.

import SwiftUI
import Lottie

// MARK: - Single Slide View
struct OnBoardingPageView: View {
    let page: OnBoardingPage
    let index: Int
    let currentPage: Int
    @State private var isPulsing = false
    @State private var iconScale: CGFloat = 0
    @State private var titleScale: CGFloat = 0
    @State private var descScale: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let outerSize = geo.size.width * 0.42
            let innerSize = outerSize * 0.75

            VStack(spacing: 24) {
                Spacer()

                // icons
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

                    if let animName = page.lottieAnimation {
                        LottieView(animation: .named(animName))
                            .playing(loopMode: page.lottieRepeatDelay > 0 ? .playOnce : .loop)
                            .configure { animationView in
                                let white = ColorValueProvider(UIColor.white.lottieColorValue)
                                animationView.setValueProvider(white, keypath: AnimationKeypath(keypath: "**.Color"))
                                animationView.animationSpeed = page.lottieSpeed
                                if page.lottieRepeatDelay > 0 {
                                    // configure re-runs on every SwiftUI
                                    // update; without the tag guard each
                                    // re-render spawned another loop chain
                                    // and the animation visibly sped up.
                                    guard animationView.tag != 0xB00 else { return }
                                    animationView.tag = 0xB00
                                    let delay = page.lottieRepeatDelay
                                    // Weak throughout: a strong capture would
                                    // keep the view (and the timer chain)
                                    // alive for the whole app lifetime after
                                    // onboarding is dismissed.
                                    func playLoop(_ view: LottieAnimationView?) {
                                        guard let view else { return }
                                        view.play { [weak view] completed in
                                            guard completed else { return }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak view] in
                                                playLoop(view)
                                            }
                                        }
                                    }
                                    playLoop(animationView)
                                }
                            }
                            .frame(width: innerSize * 0.78, height: innerSize * 0.78)
                            .scaleEffect(page.lottieScale)
                            .offset(x: page.lottieOffset.x, y: page.lottieOffset.y)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    } else {
                        Image(systemName: page.icon)
                            .font(.scaled(size: outerSize * 0.28))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(iconScale)

                // title
                Text(page.title)
                    .font(.scaled(size: 28, weight: .bold))
                    .foregroundColor(Color.brandText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .scaleEffect(titleScale)

                // description
                Text(page.description)
                    .font(.scaled(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .scaleEffect(descScale)

                Spacer()
            }
            .frame(width: geo.size.width)
        }
        .onAppear {
            // TabView pre-renders neighbouring pages; only the visible page
            // animates in. Pre-rendered neighbours settle at full scale so a
            // fast swipe can never land on a page stuck at scale 0.
            if index == currentPage {
                trigger()
            } else {
                isPulsing = true
                iconScale = 1
                titleScale = 1
                descScale = 1
            }
        }
        .onChange(of: currentPage) { _, newPage in
            if newPage == index { trigger() }
        }
    }

    private func trigger() {
        isPulsing = true
        iconScale = 0
        titleScale = 0
        descScale = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.08)) {
                titleScale = 1.0
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.14)) {
                descScale = 1.0
            }
        }
    }
}

// MARK: - Main Onboarding View
struct OnBoardingView: View {
    @StateObject private var vm = OnBoardingViewModel()
    @EnvironmentObject var appVM: ContentViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // background
            Color.brandBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // slide pages
                TabView(selection: $vm.currentPage) {
                    ForEach(0..<vm.pages.count, id: \.self) { index in
                        OnBoardingPageView(page: vm.pages[index], index: index, currentPage: vm.currentPage)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // page dots
                HStack(spacing: 8) {
                    ForEach(0..<vm.pages.count, id: \.self) { index in
                        Capsule()
                            .fill(vm.currentPage == index
                                  ? Color.brandPrimary
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
                                Text(AppStrings.back)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .foregroundColor(Color.brandPrimary)
                            .font(.scaled(size: 18, weight: .semibold))
                            .cornerRadius(Radius.card)
                            .cardShadow()
                        }
                    }

                    // next 
                    Button(action: {
                        if vm.currentPage < vm.pages.count - 1 {
                            vm.currentPage += 1
                        } else {
                            appVM.completeOnBoarding()
                        }
                    }) {
                        HStack {
                            Text(vm.currentPage == vm.pages.count - 1 ? AppStrings.getStarted : AppStrings.next)
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.brandPrimary)
                        .foregroundColor(.white)
                        .font(.scaled(size: 18, weight: .bold))
                        .cornerRadius(Radius.card)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }

            // skip button 
            if vm.currentPage < vm.pages.count - 1 {
                Button(AppStrings.skip) {
                    appVM.completeOnBoarding()
                }
                .foregroundColor(.brandText)
                .padding(.trailing, 24)
                .padding(.top, 16)
            }
        }
    }
}

#Preview {
    OnBoardingView()
        .environmentObject(ContentViewModel())
}
