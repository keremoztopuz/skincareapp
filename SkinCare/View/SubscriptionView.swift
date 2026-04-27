//
//  SubscriptionView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 24.04.2026.
//

import Foundation
import SwiftUI

struct SubscriptionView : View {
    @State private var logoScale: CGFloat = 0
    @State private var titleScale: CGFloat = 0
    @State private var isPulsing = false
    @StateObject private var vm = SubscriptionViewModel()
    @EnvironmentObject var appVM: ContentViewModel
    
    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        let outerColor = Color(red: 1.0, green: 0.87, blue: 0.87)
        
        GeometryReader { geo in
            let outerSize = geo.size.width * 0.32
            let innerSize = outerSize * 0.75
            
            ZStack {
                mainColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // logo section
                    ZStack {
                        Circle()
                            .fill(outerColor)
                            .frame(width: outerSize, height: outerSize)
                            .scaleEffect(isPulsing ? 1.12 : 1.0)
                            .animation(
                                .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                                value: isPulsing
                            )
                        
                        Circle()
                            .fill(secondaryColor)
                            .frame(width: innerSize, height: innerSize)
                        
                        Image("AppLogo")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)
                    .onAppear {
                        logoScale = 1.0
                        isPulsing = true
                    }
                    .padding(28)
                                        
                    // text section
                    VStack(spacing: 8) {
                        Text("Unlock Full Access")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                                            
                        Text("Choose the plan that works best for you")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    
                    
                    // cards section
                    HStack(spacing: 12) {
                        ZStack() {
                            // free subscription card
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                            // free section opportunities
                            VStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4){
                                    Text("Free")
                                        .font(.system(size: 28, weight: .bold))
                                        .padding(.top, 12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 12)
                                                                    
                                    Text("$0.00/month")
                                        .font(.system(size: 16, weight: .regular))
                                        .padding(.top, 4)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 12)
                                    
                                    VStack(spacing: 8) {
                                        featureRow(text: "5 skin analysis per month")
                                        featureRow(text: "Basic skin insights (Acne and Eczema)")
                                        featureRow(text: "Limited product recomendations")
                                        featureRow(text: "View last 5 recent scans")
                                    }
                                    .padding(.top, 10)
                                }
                                Spacer()
                            }
                            .padding(.top, 4)
                            .padding(.leading, 4)
                            
                        }
                                
                        ZStack() {
                            // pro subscription vard
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(outerColor)
                                .frame(maxWidth: .infinity)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                            // pro section opportunities
                            VStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pro")
                                        .font(.system(size: 28, weight: .bold))
                                        .padding(.top, 12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 12)
                                    
                                    Text("$9.99 per month")
                                        .font(.system(size: 16, weight: .regular))
                                        .padding(.top, 4)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 12)
                                    
                                    VStack(spacing: 8) {
                                        featureRow(text: "Unlimited analysis")
                                        featureRow(text: "Full skin insights (Acne, Eczema, Psoriasis, Wrinkles, Eyebags)")
                                        featureRow(text: "Unlimited product recommendation")
                                        featureRow(text: "Complete history & progress tracking")
                                    }
                                    .padding(.top, 12)
                                }
                                Spacer()
                            }
                            .padding(.top, 4)
                            .padding(.leading, 4)
                        }
                    }
                    .frame(height: 300)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // buttons section
                    VStack(spacing: 12) {
                        
                        Button(action: {
                            appVM.completePurchaseStep(isPremium: false)
                        }) {
                            Text("Continue with Free Plan")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(Color(.gray))
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 4)
                        }
                
                        Button(action: {
                            appVM.completePurchaseStep(isPremium: true)
                        }) {
                            VStack(spacing: 2) {
                                Text("Upgrade Your Plan (Free Trial)")
                                    .font(.system(size: 18, weight: .bold))
                                    
                                Text("Start your 3-day free trial")
                                    .font(.system(size: 12, weight: .regular))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(secondaryColor)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            
        }
    }
    // checkmarked text function
    func featureRow(text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .foregroundColor(Color(red:0.47, green: 0.11, blue: 0.17))
                .font(.system(size: 16))
            
            Text(text)
                .font(.system(size: 14, weight: .regular))
            
            Spacer()
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(ContentViewModel())
    }

