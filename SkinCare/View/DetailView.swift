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
    
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                BackHeaderBar(title: navigationTitle) { dismiss() }
                    .padding(.bottom, 20)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        if isLoadingFullDetail {
                            VStack {
                                Spacer()
                                ProgressView(AppStrings.loadingFullDetails)
                                    .padding(.top, 100)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            switch type {
                            case .product(let product):
                                ProductDetailContent(product: fullProduct ?? product)
                            case .news(let article):
                                ArticleDetailContent(article: fullArticle ?? article)
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
        // @MainActor: the task writes view @State, and a task created in a
        // nonisolated method would otherwise run off the main actor.
        Task { @MainActor in
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
        case .product: return AppStrings.productDetails
        case .news: return AppStrings.article
        }
    }
}

// MARK: - Product Detail Component
struct ProductDetailContent: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(Color.brandPrimary.opacity(0.05))
                    .frame(height: 350)

                if let urlString = product.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                } else {
                    Image(systemName: "bottle.condiment.fill")
                        .font(.scaled(size: 80))
                        .foregroundColor(Color.brandPrimary.opacity(0.2))
                }
            }
            .cardShadow()

            VStack(alignment: .leading, spacing: 8) {
                Text(product.brand ?? AppStrings.unknownBrand)
                    .font(.scaled(size: 14, weight: .medium))
                    .foregroundColor(.gray)

                Text(product.name)
                    .font(.scaled(size: 28, weight: .bold))
                    .foregroundColor(.brandText)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text(NSLocalizedString("description", comment: ""))
                    .font(.scaled(size: 18, weight: .bold))
                    .foregroundColor(.brandText)

                Text(product.description ?? AppStrings.noProductDescription)
                    .font(.scaled(size: 16))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }

            if let ingredients = product.activeIngredients {
                VStack(alignment: .leading, spacing: 12) {
                    Text(NSLocalizedString("active_ingredients", comment: ""))
                        .font(.scaled(size: 18, weight: .bold))
                        .foregroundColor(.brandText)

                    Text(ingredients)
                        .font(.scaled(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Article Detail Component
struct ArticleDetailContent: View {
    let article: Articles

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Image & Badge
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(Color.brandPrimary.opacity(0.1))
                    .frame(height: 250)

                if let urlString = article.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                }

                Text(article.articleType ?? AppStrings.article)
                    .font(.scaled(size: 12, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .foregroundColor(.brandPrimary)
                    .cornerRadius(Radius.small)
                    .padding(20)
            }
            .cardShadow()

            Text(article.title)
                .font(.scaled(size: 32, weight: .bold))
                .foregroundColor(.brandText)
            
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "person")
                    Text(NSLocalizedString("expert_advice", comment: ""))
                }
                if let date = article.createdAt {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text(date, style: .date)
                    }
                }
            }
            .font(.scaled(size: 14, weight: .medium))
            .foregroundColor(.gray)
            
            if let readTime = article.readTime {
                Text(String(format: NSLocalizedString("min_read", comment: ""), readTime))
                    .font(.scaled(size: 12, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.brandPrimary.opacity(0.1))
                    .foregroundColor(.brandPrimary)
                    .cornerRadius(Radius.small)
            }

            Text(article.content ?? "")
                .font(.scaled(size: 16))
                .foregroundColor(Color.brandText.opacity(0.8))
                .lineSpacing(6)
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
