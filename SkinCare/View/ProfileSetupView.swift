//
//  ProfileSetupView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 14.04.2026.
//

// THIS FILE IS FOR USER SETUP VIEWS. NAME AGE GENDER AND SKINTYPE...
// ...SELECTIONS FOR PERSONALIZE USER EXPERINCE.

import SwiftUI

// MARK: user profile setup
struct ProfileSetupView: View {
    @StateObject private var vm = ProfileSetupViewModel()
    @EnvironmentObject var appVM: ContentViewModel

    var body: some View {
        ZStack {
            Color.brandBackground
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                if vm.currentPage > 0 {
                    Button(action: {
                        vm.currentPage -= 1
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(NSLocalizedString("back", comment: ""))
                        }
                        .font(.scaled(size: 16, weight: .medium))
                        .foregroundColor(.brandPrimary)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 16)
                }
                Spacer()

                Group {
                    if vm.currentPage == 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("whats_your_name", comment: ""))
                                .font(.scaled(size: 28, weight: .bold))
                                .foregroundColor(.brandText)

                            Text(NSLocalizedString("lets_get_to_know", comment: ""))
                                .font(.scaled(size: 16))
                                .foregroundColor(.gray)

                            TextField(NSLocalizedString("enter_your_name", comment: ""), text: $vm.name)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 15)
                                .background(Color.white)
                                .cornerRadius(Radius.card)
                                .padding(.top, 16)

                            warningLabel(NSLocalizedString("please_enter_name", comment: ""), visible: vm.showNameWarning)
                        }
                        .padding(.horizontal, 28)
                    } else if vm.currentPage == 1 {
                        AgePageView(age: $vm.age)
                    } else if vm.currentPage == 2 {
                        GenderPageView(gender: $vm.gender, showWarning: vm.showGenderWarning)
                    } else if vm.currentPage == 3 {
                        SkinTypePageView(skinType: $vm.skinType, showWarning: vm.showSkinTypeWarning)
                    }
                }

                Spacer()

                Button(action: {
                    vm.handleContinue()
                }) {
                    Text(NSLocalizedString("continue", comment: ""))
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: vm.isCurrentPageValid))
                .disabled(!vm.isCurrentPageValid)
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }

        }
        .onChange(of: vm.didFinish) { _, finished in
            if finished {
                appVM.completeProfile()
            }
        }
    }
    // MARK: age selection page
    struct AgePageView: View {
        @Binding var age: Int
        var body: some View {
            VStack (alignment: .leading, spacing: 12){
                Text(NSLocalizedString("how_old", comment: ""))
                    .font(.scaled(size: 28, weight: .bold))
                    .foregroundColor(.brandText)

                Text(NSLocalizedString("helps_personalize_routines", comment: ""))
                    .font(.scaled(size: 16))
                    .foregroundColor(.gray)

                Text("\(age)")
                    .font(.scaled(size: 48, weight: .bold))
                    .foregroundColor(.brandPrimary)
                    .padding(.top, 16)

                Slider(value: Binding(
                    get: { Double(age) },
                    set: { age = Int($0) }
                ), in: 13...80, step: 1)
                .tint(Color.brandPrimary)
            }
            .padding(.horizontal, 28)
        }
    }
    // MARK: gender page
    struct GenderPageView: View {
        @Binding var gender: Gender?
        var showWarning: Bool
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(NSLocalizedString("whats_your_gender", comment: ""))
                    .font(.scaled(size: 28, weight: .bold))
                    .foregroundColor(.brandText)

                Text(NSLocalizedString("helps_tailor_recommendations", comment: ""))
                    .font(.scaled(size: 16))
                    .foregroundColor(.gray)

                VStack(spacing: 12) {
                    ForEach(Gender.allCases, id: \.self)
                    { option in
                        Button(action: { gender = option
                        }) {
                            Text(option.localizedTitle)
                                .font(.scaled(size: 16, weight: .medium))
                                .foregroundColor(gender == option ? .white : .brandText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(gender == option ? Color.brandPrimary : Color.white)
                                .cornerRadius(Radius.card)
                        }
                    }
                }
                .padding(.top, 16)

                warningLabel(NSLocalizedString("please_select_gender", comment: ""), visible: showWarning)
            }
            .padding(.horizontal, 28)
        }
    }
    // MARK: skintype page
    struct SkinTypePageView: View {
        @Binding var skinType: SkinType?
        var showWarning: Bool
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(NSLocalizedString("whats_your_skin_type", comment: ""))
                    .font(.scaled(size: 28, weight: .bold))
                    .foregroundColor(.brandText)

                Text(NSLocalizedString("customize_analysis", comment: ""))
                    .font(.scaled(size: 16))
                    .foregroundColor(.gray)

                VStack(spacing: 12) {
                    ForEach(SkinType.allCases, id: \.self)
                    { option in
                        Button(action: { skinType = option
                        }) {
                            VStack(spacing: 4) {
                                Text(option.localizedTitle)
                                    .font(.scaled(size: 16, weight: .medium))

                                Text(option.description)
                                    .font(.scaled(size: 12))

                            }
                            .foregroundColor(skinType == option ? .white : .brandText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(skinType == option ? Color.brandPrimary : Color.white)
                            .cornerRadius(Radius.card)
                        }
                    }
                }
                .padding(.top, 16)

                warningLabel(NSLocalizedString("please_select_skin_type", comment: ""), visible: showWarning)
            }
            .padding(.horizontal, 28)
        }
    }
}

// MARK: - Shared warning label
@ViewBuilder
private func warningLabel(_ text: String, visible: Bool) -> some View {
    ZStack {
        if visible {
            Text(text)
                .font(.scaled(size: 14))
                .foregroundColor(.brandPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    .frame(height: 20)
    .padding(.top, 8)
}

#Preview {
    ProfileSetupView()
        .environmentObject(ContentViewModel())
}
