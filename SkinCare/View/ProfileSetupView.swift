//
//  ProfileSetupView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 14.04.2026.
//

import SwiftUI
// gender modification
enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Prefer not to say"
}
// skin type modification
enum SkinType: String, CaseIterable {
    case normal = "Normal"
    case dry = "Dry"
    case oily = "Oily"
    case combination = "Combination"
    case sensitive = "Sensitive"
    // icons
    var icon: String {
        switch self {
        case .normal: return "checkmark.circle"
        case .dry: return "drop"
        case .oily: return "humidity"
        case .combination: return "circle.lefthalf.filled"
        case .sensitive: return "heart"
        }
    }
    // skin type description
    var description: String {
        switch self {
        case .normal: return "No major concerns."
        case .dry: return "Feels tight, may flake."
        case .oily: return "Shiny, feels greasy."
        case .combination: return "Oily T-zone, dry cheeks."
        case .sensitive: return "Reacts easily to products."
        }
    }
}
// MARK: - Profile Setup View
struct ProfileSetupView: View {
    @State private var currentPage: Int = 0
    @State private var name: String = ""
    @State private var gender: Gender? = nil
    @State private var age: Int = 25
    @State private var height: Int = 170
    @State private var weight: Int = 70
    @State private var skinType: SkinType? = nil
    @AppStorage("hasCompletedProfile") private var hasCompletedProfile = false
    
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.97, blue: 0.97).ignoresSafeArea()
            VStack {
                
            }
        }
    }
}
// MARK: - Name Page View
struct NamePageView: View {
    @Binding var name: String
    var body: some View {
        VStack(spacing: 32) {
            Text("What's your name?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            Text("We'll use this to personaliza your experince")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
            TextField("Your name", text: $name)
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 40)
            Spacer()
            Spacer()
                
        }
    }
}


#Preview {
    NamePageView(name: .constant(""))
}


