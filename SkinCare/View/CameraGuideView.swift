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
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 12) {
                BrandCircleIcon(systemImage: "camera.fill", size: 80, animated: true)

                Text(NSLocalizedString("camera_guidelines", comment: ""))
                    .font(.scaled(size: 28, weight: .bold))
                    .foregroundColor(.brandText)

                Text(NSLocalizedString("follow_essentials", comment: ""))
                    .font(.scaled(size: 15, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.brandPrimary)

                            Text(NSLocalizedString("dos", comment: ""))
                                .font(.scaled(size: 17, weight: .semibold))
                        }

                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                guideImage("guidegood1")
                                guideImage("guidegood2")
                            }

                            HStack(spacing: 6) {
                                guideImage("guidegood3")
                                guideImage("guidegood4")
                            }
                        }
                        .frame(height: 166)

                        VStack(alignment: .leading, spacing: 16) {
                            BulletRow(text: NSLocalizedString("guide_do_position_face", comment: ""), icon: "checkmark.circle.fill")
                            BulletRow(text: NSLocalizedString("guide_do_good_lighting", comment: ""), icon: "checkmark.circle.fill")
                            BulletRow(text: NSLocalizedString("guide_do_center_face", comment: ""), icon: "checkmark.circle.fill")
                            BulletRow(text: NSLocalizedString("guide_do_hold_steady", comment: ""), icon: "checkmark.circle.fill")
                            BulletRow(text: NSLocalizedString("guide_do_remove_accessories", comment: ""), icon: "checkmark.circle.fill")
                        }
                        .padding(.top, 8)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.brandPrimary)

                            Text(NSLocalizedString("donts", comment: ""))
                                .font(.scaled(size: 17, weight: .semibold))
                        }
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                guideImage("guidebad1")
                                guideImage("guidebad2")
                            }

                            HStack(spacing: 6) {
                                guideImage("guidebad3")
                                guideImage("guidebad4")
                            }
                        }
                        .frame(height: 166)
                        VStack(alignment: .leading, spacing: 16) {
                            BulletRow(text: NSLocalizedString("guide_dont_move", comment: ""), icon: "xmark.circle.fill")
                            BulletRow(text: NSLocalizedString("guide_dont_makeup", comment: ""), icon: "xmark.circle.fill")
                            BulletRow(text: NSLocalizedString("guide_dont_shadows", comment: ""), icon: "xmark.circle.fill")
                            BulletRow(text: NSLocalizedString("guide_dont_tilt", comment: ""), icon: "xmark.circle.fill")
                            BulletRow(text: NSLocalizedString("guide_dont_filters", comment: ""), icon: "xmark.circle.fill")
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
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
        .background(Color.brandBackground.ignoresSafeArea())
    }

    @ViewBuilder
    private func guideImage(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipped()
            .cornerRadius(Radius.small)
    }
}

struct BulletRow: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.brandPrimary)
                .font(.scaled(size: 18))
                .padding(.top, -1)
            Text(text)
                .font(.scaled(size: 13, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    CameraGuideView()
}
