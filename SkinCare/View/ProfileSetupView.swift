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
            Color(red: 1.0, green: 0.97, blue: 0.97)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                if vm.currentPage > 0 {
                    Button(action: {
                        vm.currentPage -= 1
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.47, green: 0.11, blue: 0.17))
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 16)
                }
                Spacer()
                
                Group {
                    if vm.currentPage == 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What's your name?")
                                .font(.system(size: 28, weight:
                                        .bold))
                                .foregroundColor(Color(red: 0.1,
                                                       green: 0.1, blue: 0.2))
                            
                            Text("Let's get to know you")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            TextField("Enter your name", text: $vm.name)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 15)
                                .background(Color.white)
                                .cornerRadius(12)
                                .padding(.top, 16)
                            
                            ZStack {
                                if vm.showNameWarning {
                                    Text("Please enter your name.")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red:
                                        0.47, green: 0.11, blue: 0.17))
                                        .frame(maxWidth: .infinity,
                                               alignment: .leading)
                                }
                            }
                            .frame(height: 20)
                            .padding(.top, 8)
                        }
                        .frame(height: 220)
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
                    Text("Continue")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(vm.isCurrentPageValid
                              ? Color(red: 0.47, green: 0.11, blue: 0.17)
                              : Color.gray.opacity(0.4))
                }
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
                Text("How old are you?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.1,
                                           green: 0.1, blue: 0.2))
                
                Text("Helps us personalize your routines")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Text("\(age)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(red: 0.47,
                                           green: 0.11, blue: 0.17))
                    .padding(.top, 16)
                
                Slider(value: Binding(
                    get: { Double(age) },
                    set: { age = Int($0) }
                ), in: 13...80, step: 1)
                .tint(Color(red: 0.47, green: 0.11, blue: 0.17))
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
                Text("What's your gender?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))

                Text("Helps us tailor your recommendations")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)

                VStack(spacing: 12) {
                    ForEach(Gender.allCases, id: \.self)
                    { option in
                        Button(action: { gender = option
                        }) {
                            Text(option.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(gender == option ? .white : Color(red: 0.1, green: 0.1, blue: 0.2))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(gender == option ? Color(red: 0.47, green: 0.11, blue: 0.17) : Color.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.top, 16)

                ZStack {
                    if showWarning {
                        Text("Please select your gender.")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.47, green: 0.11, blue: 0.17))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .frame(height: 20)
                .padding(.top, 8)
            }
            .padding(.horizontal, 28)
        }
    }
    // MARK: skintype page
    struct SkinTypePageView: View {
        @Binding var skinType: SkinType?
        var showWarning: Bool
        var body: some View {
            let selectedColor = Color(red: 0.47, green: 0.11, blue: 0.17)
            let darkColor = Color(red: 0.1, green: 0.1, blue: 0.2)
            VStack(alignment: .leading, spacing: 12) {
                Text("What's your skin type?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))

                Text("We'll customize your analysis")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)

                VStack(spacing: 12) {
                    ForEach(SkinType.allCases, id: \.self)
                    { option in
                        Button(action: { skinType = option
                        }) {
                            VStack(spacing: 4) {
                                Text(option.rawValue)
                                    .font(.system(size: 16, weight: .medium))

                                Text(option.description)
                                    .font(.system(size: 12))

                            }
                            .foregroundColor(skinType == option ? .white : darkColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(skinType == option ? selectedColor : .white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.top, 16)

                ZStack {
                    if showWarning {
                        Text("Please select your skin type.")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.47, green: 0.11, blue: 0.17))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .frame(height: 20)
                .padding(.top, 8)
            }
            .padding(.horizontal, 28)
        }
    }
}
#Preview {
    ProfileSetupView()
        .environmentObject(ContentViewModel())
}
    
