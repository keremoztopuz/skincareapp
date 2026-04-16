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

struct ProfileSetupView: View {
      @State private var currentPage = 0
      @State private var name = ""
      @State private var age = 25
      @State private var gender: Gender? = nil
      @State private var skinType: SkinType? = nil
      @State private var showNameWarning = false
    
      var body: some View {
          ZStack {
              Color(red: 1.0, green: 0.97, blue: 0.97)
                  .ignoresSafeArea()
              VStack(alignment: .leading, spacing: 0) {
                  Spacer()
                  VStack(alignment: .leading, spacing: 12){
                      Text("What's your name?")
                          .font(.system(size:28, weight: .bold))
                          .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                      
                      Text("Let's get to know you")
                          .font(.system(size: 16))
                          .foregroundColor(.gray)
                      
                      TextField("Enter your name", text: $name)
                          .padding(.vertical, 12)
                          .padding(.horizontal, 15)
                          .background(Color.white)
                          .cornerRadius(12)
                          .padding(.top, 16)
                      
                      ZStack {
                          if showNameWarning {
                              Text("Please enter your name.")
                                  .font(.system(size: 14))
                                  .foregroundColor(Color(red:0.47, green: 0.11, blue: 0.17))
                                  .padding(.horizontal)
                                  .padding(.bottom, 24)
                                  .frame(maxWidth: .infinity, alignment: .leading)
                          }
                      }
                      .frame(height: 20)
                      .padding(.top, 8)
                  }
                  .frame(height: 220)
                  .padding(.horizontal, 28)
                  
                  
                  Spacer()
                  
                  Button(action: {
                      if name.trimmingCharacters(in: .whitespaces).isEmpty {
                          showNameWarning = true
                      } else {
                          currentPage = 1
                      }
                  }) {
                      Text("Continue")
                          .font(.system(size: 18, weight: .bold))
                          .foregroundColor(.white)
                          .frame(maxWidth: .infinity)
                          .padding(.vertical, 18)
                          .background(Color(red: 0.47, green: 0.11,
                  blue: 0.17))
                          .cornerRadius(16)
                            }
                          .padding(.horizontal, 28)
                          .padding(.bottom, 48)
                  }
                  
              }
          }
    }

struct AgePageView: View {
    var body: some View {
        Text("Hello, world!")
    }
}
  

#Preview {
    ProfileSetupView()
}


