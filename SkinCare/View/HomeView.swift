//
//  HomeView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
import SwiftUI
import Lottie
internal import Combine

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    // greetings by time
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<18: return "Good Afternoon"
        case 18..<22: return "Good Evening"
        default: return "Good Night"
        }
    }
    // routine cards info
    private var routineInfo: (title: String, description: String, icon: String, products: [String]) {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 17 {
            return ("Morning Routine", "Start your day with these essential steps.", "sun.max.fill", ["Cleanser", "Toner", "SPF 50+"])
        } else {
            return ("Night Routine", "End your day with these essential steps.", "moon.stars.fill", ["Cleanser", "Serum", "Moisturizer"])
        }
    }
    // MARK: Main View
    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        let outerColor = Color(red: 1.0, green: 0.87, blue: 0.87)
        
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(greetingText), \(vm.userName)")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Let's take care of your skin today")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 18)
            // analysis button
            Button(action: {
                print("analysis started")
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(outerColor)
                        .frame(width: 370, height: 230 ,alignment: .center)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                    
                    VStack(alignment: .center) {
                        Circle()
                            .fill(secondaryColor)
                            .frame(width: 150, height: 150, alignment: .center)
                            .overlay {
                                VStack(spacing: -18) {
                                    LottieView(animation: .named("AI Star loader UI"))
                                        .playing(loopMode: .loop)
                                        .configure { animationView in
                                            let white = ColorValueProvider(UIColor.white.lottieColorValue)
                                            animationView.setValueProvider(white, keypath: AnimationKeypath(keypath: "**.Color"))
                                        }
                                        .frame(width: 90, height: 90)
                                        .padding(.leading, 10)
                                    
                                    Text("Skin analysis")
                                        .padding()
                                        .foregroundColor(mainColor)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                    }
                    
                }
                .padding(.top, 12)
            }
            // summaries
            VStack(spacing: 8){
                Text("Your skin health")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 6)
                
                // metric cards
                HStack(spacing: 8){
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                            .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                        VStack(spacing: 4) {
                            Text("85")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 12)
                            Text("Skin Score")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                    }
                    .padding(.top, 12)
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                            .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                        VStack(spacing: 4) {
                            Text("85")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 12)
                            Text("Skin Score")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                    
                }
                HStack(spacing: 8){
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                            .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                        VStack(spacing: 4) {
                            Text("85")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 12)
                            Text("Skin Score")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                            .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                        VStack(spacing: 4) {
                            Text("85")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 12)
                            Text("Skin Score")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)
            // recommendation card
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Recommendations")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top,12)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(secondaryColor)
                        .frame(maxWidth: .infinity, minHeight: 200)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(routineInfo.title)
                                .font(.system(size: 28, weight: .bold))
                            
                            Spacer()
                            
                            Image(systemName: routineInfo.icon)
                                .font(.system(size: 24))
                        }
                        
                        Text(routineInfo.description)
                            .font(.system(size: 18, weight: .medium))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(0.9)
                        
                        HStack(spacing: 8) {
                            ForEach(routineInfo.products, id: \.self) { product in
                                Text(product)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .foregroundColor(.white)
                    .padding(24)
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            Spacer()
        }
        .background(mainColor.ignoresSafeArea())
    }
}

#Preview {
    HomeView()
}
