//
//  DetailView.swift
//  SkinCare
//
//  Created by SkinCare on 13.05.2026.
//

import SwiftUI

enum DetailType {
    case product(Product)
    case news(Articles)
}

struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    let type: DetailType
    @State private var fullProduct: Product?
    @State private var fullArticle: Articles?
    @State private var isLoadingFullDetail = false
    
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
                    
                    // Right actions (Heart for product, Share/Save for articles)
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        if isLoadingFullDetail {
                            VStack {
                                Spacer()
                                ProgressView("Loading full details...")
                                    .padding(.top, 100)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            switch type {
                            case .product(let product):
                                ProductDetailContent(product: fullProduct ?? product, secondaryColor: secondaryColor, primaryText: primaryText)
                            case .news(let article):
                                ArticleDetailContent(article: fullArticle ?? article, secondaryColor: secondaryColor, primaryText: primaryText)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadFullDetail()
        }
    }
    
    private func loadFullDetail() {
        isLoadingFullDetail = true
        Task {
            do {
                switch type {
                case .product(let product):
                    self.fullProduct = try await SupabaseService.shared.fetchProductDetail(id: product.id)
                case .news(let article):
                    self.fullArticle = try await SupabaseService.shared.fetchArticleDetail(id: article.id)
                }
            } catch {
                print("Failed to fetch full detail: \(error)")
            }
            isLoadingFullDetail = false
        }
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
                
                if let urlString = product.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                } else {
                    Image(systemName: "bottle.condiment.fill")
                        .font(.system(size: 80))
                        .foregroundColor(secondaryColor.opacity(0.2))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.brand ?? "Unknown Brand")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(product.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(primaryText)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Description")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(primaryText)
                
                Text(product.description ?? "No description available for this product.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            
            if let ingredients = product.activeIngredients {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Ingredients")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(primaryText)
                    
                    Text(ingredients)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Article Detail Component
struct ArticleDetailContent: View {
    let article: Articles
    let secondaryColor: Color
    let primaryText: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Image & Badge
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 25)
                    .fill(secondaryColor.opacity(0.1))
                    .frame(height: 250)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                if let urlString = article.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                }

                Text(article.articleType ?? "Article")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .foregroundColor(secondaryColor)
                    .cornerRadius(8)
                    .padding(20)
            }
            
            Text(article.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(primaryText)
            
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "person")
                    Text("Expert Advice")
                }
                if let date = article.createdAt {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text(date, style: .date)
                    }
                }
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.gray)
            
            if let readTime = article.readTime {
                Text("\(readTime) min read")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(secondaryColor.opacity(0.1))
                    .foregroundColor(secondaryColor)
                    .cornerRadius(6)
            }
            
            Text(article.content)
                .font(.system(size: 16))
                .foregroundColor(primaryText.opacity(0.8))
                .lineSpacing(6)
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
        brand: "GlowLab",
        description: "A lightweight, fast-absorbing serum.",
        imageUrl: nil,
        productType: "Serum",
        activeIngredients: "Hyaluronic Acid",
        usageTime: "Night",
        frequency: "Daily",
        contraindications: nil,
        skinTypes: ["Dry", "Normal"],
        isActive: true
    )))
}

#Preview("Article Detail") {
    DetailView(type: .news(Articles(
        id: UUID(),
        title: "10 Essential Tips for Winter Skin Care",
        content: "Winter can be harsh on your skin...",
        imageUrl: nil,
        readTime: 5,
        articleType: "Tips",
        isActive: true,
        isFixed: false,
        createdAt: Date()
    )))
}
