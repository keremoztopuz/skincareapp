//
//  ProfileView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        //let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
        
        ZStack {
            mainColor.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Skin Journey")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(primaryText)
                        
                        Text("Track your progress over time")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Placeholder for stats or charts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weekly Progress")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(primaryText)
                        
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .frame(height: 200)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            .overlay {
                                Text("Your skin data will appear here")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Achievements")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(primaryText)
                        
                        HStack(spacing: 12) {
                            AchievementIcon(icon: "star.fill", label: "7 Day Streak")
                            AchievementIcon(icon: "heart.fill", label: "Consistent")
                            AchievementIcon(icon: "sparkles", label: "Glowing")
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
    }
}

struct AchievementIcon: View {
    let icon: String
    let label: String
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(secondaryColor.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(secondaryColor)
            }
            
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
