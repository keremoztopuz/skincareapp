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
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                
                // greeting Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(greetingText), \(vm.userName)")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("Let's take care of your skin today")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // analysis Button
                Button(action: {
                    print("analysis started")
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(outerColor)
                            .frame(height: 230)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                        
                        Circle()
                            .fill(secondaryColor)
                            .frame(width: 150, height: 150)
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
                                        .padding(.top, -12)
                                    
                                    Text("Skin analysis")
                                        .foregroundColor(mainColor)
                                        .font(.system(size: 16, weight: .semibold))
                                        .padding(.top, 15)
                                }
                            }
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                    }
                }
                .padding(.horizontal, 20)
                
                // skin health grid
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your skin health")
                        .font(.system(size: 24, weight: .bold))
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            MetricCard(value: "85", label: "Skin Score")
                            MetricCard(value: "85", label: "Skin Score")
                        }
                        HStack(spacing: 12) {
                            MetricCard(value: "85", label: "Skin Score")
                            MetricCard(value: "85", label: "Skin Score")
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // recommendation card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Recommendations")
                        .font(.system(size: 24, weight: .bold))
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(secondaryColor)
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)

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
                }
                .padding(.horizontal, 20)
                
                // products horizontal list
                VStack(alignment: .leading, spacing: 16) {
                    Text("Products")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(vm.products) { product in
                                Button(action: {
                                    print("\(product.name) clicked")
                                }) {
                                    ProductCard(product: product)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("News")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 16) {
                            ForEach(vm.news) { news in
                                Button(action: {
                                    print("\(news.title) clicked")
                                }) {
                                    NewsCard(news: news)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // bottom spacing
                Color.clear.frame(height: 20)
            }
        }
        .background(mainColor.ignoresSafeArea())
    }
}

// MARK: - Subviews
struct MetricCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
            
            Text(label)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.leading, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 100)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
    }
}

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 140, height: 140)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                Text(product.category)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .frame(height: 50, alignment: .top)
        }
        .frame(width: 140)
    }
}

struct NewsCard: View {
    let news: News
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 300, height: 300)
            VStack(alignment: .leading, spacing: 2){
                Text(news.title)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                Text(news.content)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
#Preview {
    HomeView()
}
