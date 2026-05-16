//
//  DetailView.swift
//  SkinCare
//
//  Created by SkinCare on 13.05.2026.
//

import SwiftUI

enum DetailType {
    case product(Product)
    case news(News)
}

struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    let type: DetailType
    
    let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    
    var body: some View {
        ZStack {
            mainColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(secondaryColor)
                            .clipShape(Circle())
                            .shadow(color: secondaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    
                    Spacer()
                    
                    Text(navigationTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(primaryText)
                    
                    Spacer()
                    
                    // Right actions (Heart for product, Share/Save for news)
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        switch type {
                        case .product(let product):
                            ProductDetailContent(product: product, secondaryColor: secondaryColor, primaryText: primaryText)
                        case .news(let news):
                            NewsDetailContent(news: news, secondaryColor: secondaryColor, primaryText: primaryText)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var navigationTitle: String {
        switch type {
        case .product: return "Product Details"
        case .news: return "Article"
        }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        switch type {
        case .product:
            Button(action: {}) {
                Image(systemName: "heart")
                    .font(.system(size: 20))
                    .foregroundColor(primaryText)
            }
        case .news:
            HStack(spacing: 20) {
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 20))
                }
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                }
            }
            .foregroundColor(primaryText)
        }
    }
}

// MARK: - Product Detail Component
struct ProductDetailContent: View {
    let product: Product
    let secondaryColor: Color
    let primaryText: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(secondaryColor.opacity(0.05))
                    .frame(height: 350)
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
                
                Image(systemName: "bottle.condiment.fill")
                    .font(.system(size: 80))
                    .foregroundColor(secondaryColor.opacity(0.2))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("GlowLab") // Stub brand - should come from Supabase
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(product.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(primaryText)
                
                HStack(spacing: 4) {
                    ForEach(0..<4) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                    }
                    Image(systemName: "star.leadinghalf.filled")
                        .foregroundColor(.orange)
                    
                    Text("4.8 (1234 reviews)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Description")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(primaryText)
                
                Text("A lightweight, fast-absorbing serum that delivers intense hydration to your skin. Formulated with hyaluronic acid and vitamin E for long-lasting moisture.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
        }
    }
}

// MARK: - News Detail Component
struct NewsDetailContent: View {
    let news: News
    let secondaryColor: Color
    let primaryText: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Image & Category Badge
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 25)
                    .fill(secondaryColor)
                    .frame(height: 250)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Text("Skincare Tips")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .foregroundColor(secondaryColor)
                    .cornerRadius(8)
                    .padding(20)
            }
            
            Text(news.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(primaryText)
            
            HStack(spacing: 20) {
                Label("Dr. Sarah Mitchell", systemImage: "person")
                Label("May 10, 2026", systemImage: "calendar")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.gray)
            
            Text("5 min read")
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(secondaryColor.opacity(0.1))
                .foregroundColor(secondaryColor)
                .cornerRadius(6)
            
            Text(news.content)
                .font(.system(size: 16))
                .foregroundColor(primaryText.opacity(0.8))
                .lineSpacing(6)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Related Topics")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(primaryText)
                
                FlowLayout(spacing: 10) {
                    TopicBadge(text: "Skincare")
                    TopicBadge(text: "Beauty Tips")
                    TopicBadge(text: "Health")
                    TopicBadge(text: "Wellness")
                }
            }
            .padding(.top, 10)
        }
    }
}

struct TopicBadge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

struct FlowLayout: View {
    let spacing: CGFloat
    let content: [AnyView]
    
    init<Views>(spacing: CGFloat, @ViewBuilder content: () -> Views) where Views: View {
        self.spacing = spacing
        self.content = [AnyView(content())]
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<content.count, id: \.self) { index in
                content[index]
            }
        }
    }
}

#Preview("Product Detail") {
    DetailView(type: .product(Product(
        id: UUID(),
        name: "Hydrating Serum",
        category: "GlowLab",
        imageName: "bottle.condiment.fill"
    )))
}

#Preview("News Detail") {
    DetailView(type: .news(News(
        id: UUID(),
        title: "10 Essential Tips for Winter Skin Care",
        content: "Winter can be harsh on your skin, but with the right approach, you can keep it healthy and glowing throughout the cold months. Here are ten essential tips to protect and nourish your skin during winter.\n\n1. Hydrate from Within: Drink plenty of water throughout the day...",
        createdAt: Date()
    )))
}
