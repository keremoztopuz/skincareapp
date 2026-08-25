import SwiftUI
import Lottie

struct DisclaimerView: View {
    @EnvironmentObject var appVM: ContentViewModel
    @State private var hasAccepted = false
    @State private var isPulsing = false
    @State private var iconScale: CGFloat = 0
    @State private var contentScale: CGFloat = 0

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // The notice scrolls when it is taller than the screen; the
                // consent checkbox and Continue button stay pinned below so
                // they can never be pushed out of reach.
                ScrollView {
                VStack(spacing: 0) {
                Spacer(minLength: 12)

                ZStack {
                    Circle()
                        .fill(Color.brandBlush)
                        .frame(width: 160, height: 160)
                        .scaleEffect(isPulsing ? 1.12 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                    Circle()
                        .fill(Color.brandPrimary)
                        .frame(width: 115, height: 115)

                    LottieView(animation: .named("Disclaimer"))
                        .playing(loopMode: .loop)
                        .configure { animationView in
                            let white = ColorValueProvider(UIColor.white.lottieColorValue)
                            let burgundy = ColorValueProvider(UIColor(Color.brandPrimary).lottieColorValue)

                            animationView.setValueProvider(white, keypath: AnimationKeypath(keypath: "body.Shape 1.Fill 1.Color"))
                            animationView.setValueProvider(white, keypath: AnimationKeypath(keypath: "stroke.Shape 1.Stroke 1.Color"))

                            animationView.setValueProvider(burgundy, keypath: AnimationKeypath(keypath: "Shape Layer 3.Ellipse 1.Fill 1.Color"))
                            animationView.setValueProvider(burgundy, keypath: AnimationKeypath(keypath: "Shape Layer 2.Shape 1.Fill 1.Color"))
                        }
                        .frame(width: 75, height: 75)
                }
                .scaleEffect(iconScale)
                .padding(.bottom, 28)

                VStack(spacing: 24) {
                    Text(NSLocalizedString("important_notice", comment: ""))
                        .font(.scaled(size: 28, weight: .bold))
                        .foregroundColor(.brandText)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 16) {
                        DisclaimerItem(
                            icon: "cross.case.fill",
                            text: NSLocalizedString("disclaimer_medical", comment: "")
                        )

                        DisclaimerItem(
                            icon: "allergens.fill",
                            text: NSLocalizedString("disclaimer_patch_test", comment: "")
                        )

                        DisclaimerItem(
                            icon: "hand.raised.fill",
                            text: NSLocalizedString("disclaimer_liability", comment: "")
                        )

                    }
                    .padding(.horizontal, 8)
                }
                .scaleEffect(contentScale)

                Spacer(minLength: 20)
                }
                }
                .scrollBounceBehavior(.basedOnSize)

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        hasAccepted.toggle()
                    }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: Radius.small)
                                .stroke(hasAccepted ? Color.brandPrimary : Color.gray.opacity(0.4), lineWidth: 2)
                                .frame(width: 24, height: 24)

                            if hasAccepted {
                                Image(systemName: "checkmark")
                                    .font(.scaled(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.brandPrimary)
                                    .cornerRadius(Radius.small)
                                    .transition(.scale)
                            }
                        }

                        Text(NSLocalizedString("accept_terms", comment: ""))
                            .font(.scaled(size: 15, weight: .medium))
                            .foregroundColor(.brandText)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)

                Button {
                    appVM.acceptDisclaimer()
                } label: {
                    HStack {
                        Text(NSLocalizedString("continue", comment: ""))
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(hasAccepted ? Color.brandPrimary : Color.gray.opacity(0.3))
                    .foregroundColor(hasAccepted ? .white : .gray)
                    .font(.scaled(size: 18, weight: .bold))
                    .cornerRadius(Radius.card)
                }
                .disabled(!hasAccepted)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isPulsing = true
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
                contentScale = 1.0
            }
        }
    }
}

struct DisclaimerItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.brandBlush)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.scaled(size: 16))
                    .foregroundColor(.brandPrimary)
            }

            Text(text)
                .font(.scaled(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    DisclaimerView()
        .environmentObject(ContentViewModel())
}
