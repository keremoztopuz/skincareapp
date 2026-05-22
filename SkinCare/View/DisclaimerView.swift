import SwiftUI
import Lottie

struct DisclaimerView: View {
    @EnvironmentObject var appVM: ContentViewModel
    @State private var hasAccepted = false
    @State private var isPulsing = false
    @State private var iconScale: CGFloat = 0
    @State private var contentScale: CGFloat = 0

    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
    let outerColor = Color(red: 1.0, green: 0.87, blue: 0.87)
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)

    var body: some View {
        ZStack {
            mainColor.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(outerColor)
                        .frame(width: 160, height: 160)
                        .scaleEffect(isPulsing ? 1.12 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                    Circle()
                        .fill(secondaryColor)
                        .frame(width: 115, height: 115)

                    LottieView(animation: .named("Disclaimer"))
                        .playing(loopMode: .loop)
                        .configure { animationView in
                            let white = ColorValueProvider(UIColor.white.lottieColorValue)
                            let burgundy = ColorValueProvider(UIColor(red: 0.47, green: 0.11, blue: 0.17, alpha: 1.0).lottieColorValue)

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
                    Text("Important Notice")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(primaryText)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 16) {
                        DisclaimerItem(
                            icon: "cross.case.fill",
                            text: "This app does not provide medical diagnosis or treatment. The analyses are for informational purposes only and do not replace professional medical advice."
                        )

                        DisclaimerItem(
                            icon: "allergens.fill",
                            text: "Before using any recommended product, apply a small amount to a patch of skin and wait 24 hours to check for allergic reactions."
                        )

                        DisclaimerItem(
                            icon: "hand.raised.fill",
                            text: "We accept no liability for any adverse reactions or outcomes resulting from the use of recommended products. Use all suggestions at your own risk."
                        )
                    }
                    .padding(.horizontal, 8)
                }
                .scaleEffect(contentScale)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        hasAccepted.toggle()
                    }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(hasAccepted ? secondaryColor : Color.gray.opacity(0.4), lineWidth: 2)
                                .frame(width: 24, height: 24)

                            if hasAccepted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(secondaryColor)
                                    .cornerRadius(6)
                                    .transition(.scale)
                            }
                        }

                        Text("I have read and accept the terms above")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(primaryText)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)

                Button {
                    appVM.acceptDisclaimer()
                } label: {
                    HStack {
                        Text("Continue")
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(hasAccepted ? secondaryColor : Color.gray.opacity(0.3))
                    .foregroundColor(hasAccepted ? .white : .gray)
                    .font(.system(size: 18, weight: .bold))
                    .cornerRadius(16)
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
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.87, blue: 0.87))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(secondaryColor)
            }

            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    DisclaimerView()
        .environmentObject(ContentViewModel())
}
