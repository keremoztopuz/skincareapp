//
//  CameraGuideView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 5.05.2026.
//

import Foundation
import SwiftUI

struct CameraGuideView: View {
    @AppStorage("hasSeenCameraGuide") private var hasSeenCameraGuide = false
    @State private var isPulsing = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        let outerColor = Color(red: 1.0, green: 0.87, blue: 0.87)
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(outerColor)
                        .frame(width: 80, height: 80)
                        .scaleEffect(isPulsing ? 1.12 : 1.0)
                        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: isPulsing)
                    
                    Circle()
                        .fill(secondaryColor)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .onAppear { isPulsing = true }
                
                Text(NSLocalizedString("camera_guidelines", comment: ""))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Text(NSLocalizedString("follow_essentials", comment: ""))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(secondaryColor)
                            
                            Text(NSLocalizedString("dos", comment: ""))
                                .font(.system(size: 17, weight: .semibold))
                        }
                        
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image("guidegood1")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                                Image("guidegood2")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                            }
                            
                            HStack {
                                Image("guidegood3")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                                Image("guidegood4")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                            }
                            
                        }
                        .frame(height: 166)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            BulletRow(text: NSLocalizedString("guide_do_position_face", comment: ""), icon: "checkmark.circle.fill", color: secondaryColor)
                            BulletRow(text: NSLocalizedString("guide_do_good_lighting", comment: ""), icon: "checkmark.circle.fill", color: secondaryColor)
                            BulletRow(text: NSLocalizedString("guide_do_center_face", comment: ""), icon: "checkmark.circle.fill", color: secondaryColor)
                            BulletRow(text: NSLocalizedString("guide_do_hold_steady", comment: ""), icon: "checkmark.circle.fill", color: secondaryColor)
                            BulletRow(text: NSLocalizedString("guide_do_remove_accessories", comment: ""), icon: "checkmark.circle.fill", color: secondaryColor)
                        }
                        .padding(.top, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(secondaryColor)
                            
                            Text(NSLocalizedString("donts", comment: ""))
                                .font(.system(size: 17, weight: .semibold))
                        }
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image("guidebad1")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                                Image("guidebad2")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                            }
                            
                            HStack {
                                Image("guidebad3")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                                Image("guidebad4")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                            }
                            
                        }
                        .frame(height: 166)
                        VStack(alignment: .leading, spacing: 17) {
                            BulletRow(text: NSLocalizedString("guide_dont_move", comment: ""), icon: "xmark.circle.fill", color: secondaryColor)
                            BulletRow(text: NSLocalizedString("guide_dont_makeup", comment: ""), icon: "xmark.circle.fill", color: secondaryColor)
                            BulletRow(text: NSLocalizedString("guide_dont_shadows", comment: ""), icon: "xmark.circle.fill", color: secondaryColor)
                            BulletRow(text: NSLocalizedString("guide_dont_tilt", comment: ""), icon: "xmark.circle.fill", color: secondaryColor)
                            BulletRow(text: NSLocalizedString("guide_dont_filters", comment: ""), icon: "xmark.circle.fill", color: secondaryColor)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            }
            
            Spacer()
            
            Button(action: {
                hasSeenCameraGuide = true
                dismiss()
            }) {
                Text(NSLocalizedString("next", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(secondaryColor)
                    .cornerRadius(16)
                    .shadow(color: secondaryColor.opacity(0.3), radius: 10, x: 0,
                            y: 5)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
        .background(mainColor.ignoresSafeArea())

    }
}

struct BulletRow: View {
    let text: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
                .padding(.top, -1)
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview{
    CameraGuideView()
}
