//
//  ResultView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
import SwiftUI

struct ResultView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: ResultsViewModel
    var onDismiss: (() -> Void)? = nil
    
    let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    
    let record: AnalysisRecord?
    let isFromRecents: Bool
    @State private var showRecommendations = false
    @State private var selectedProduct: Product? = nil
    @State private var showProductDetail = false
    @State private var showUpgrade = false

    private var isPremium: Bool { SubscriptionManager.shared.isPremium }
    
    init(record: AnalysisRecord?, isFromRecents: Bool, onDismiss: (() -> Void)? = nil) {
        self.record = record
        self.isFromRecents = isFromRecents
        self.onDismiss = onDismiss
        self._vm = StateObject(wrappedValue: ResultsViewModel(record: record))
    }
    
    var body: some View {
        ZStack {
            mainColor.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - Back Button
                    HStack {
                        Button(action: { 
                            if let onDismiss = onDismiss {
                                onDismiss()
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(secondaryColor)
                                .clipShape(Circle())
                                .shadow(color: secondaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // MARK: - Scanned Image Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Scanned Image")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(primaryText)
                        
                        ZStack {
                            if let data = record?.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            colors: [secondaryColor.opacity(0.1), secondaryColor.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay {
                                        Image(systemName: "camera.viewfinder")
                                            .font(.system(size: 50))
                                            .foregroundColor(secondaryColor.opacity(0.3))
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 370)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, isFromRecents ? 0 : 20)
                    
                    // MARK: - Results Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Results")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(primaryText)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ResultBar(title: "Acne",     score: record?.acneScore    ?? 0, icon: "face.dashed",  color: secondaryColor)
                                ResultBar(title: "Redness",   score: record?.eczemaScore  ?? 0, icon: "drop.fill",    color: secondaryColor)
                                if isPremium {
                                    ResultBar(title: "Wrinkles",  score: record?.wrinkleScore   ?? 0, icon: "sun.max.fill",  color: secondaryColor)
                                    ResultBar(title: "Eyebags",   score: record?.eyebagScore    ?? 0, icon: "flame.fill",    color: secondaryColor)
                                    ResultBar(title: "Psoriasis", score: record?.psoriasisScore ?? 0, icon: "face.smiling",  color: secondaryColor)
                                } else {
                                    Button { showUpgrade = true } label: { lockedBar(title: "Wrinkles") }.buttonStyle(.plain)
                                    Button { showUpgrade = true } label: { lockedBar(title: "Eyebags") }.buttonStyle(.plain)
                                    Button { showUpgrade = true } label: { lockedBar(title: "Psoriasis") }.buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // MARK: - Recommended Products
                    if isFromRecents || showRecommendations {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recommended Products")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(primaryText)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    if vm.isLoading {
                                        ProgressView()
                                            .frame(width: 160, height: 160)
                                    } else {
                                        ForEach(isPremium ? vm.recommendProduct : Array(vm.recommendProduct.prefix(2))) { product in
                                            Button {
                                                selectedProduct = product
                                                showProductDetail = true
                                            } label: {
                                                ProductCard(product: product)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }                        }
                    }
                    
                    // MARK: - Action Button (Only for Fresh Analysis)
                    if !isFromRecents && !showRecommendations {
                        Button(action: {
                            withAnimation { showRecommendations = true }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 20))
                                Text("See Recommendations")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 22)
                            .background(secondaryColor)
                            .cornerRadius(20)
                            .shadow(color: secondaryColor.opacity(0.3), radius: 10, x: 0, y: 8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    } else {
                        // Bottom spacing for Recents mode
                        Color.clear.frame(height: 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showUpgrade) { UpgradeSheetView() }
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                NavigationStack {
                    DetailView(type: .product(product))
                }
            }
        }
    }

    @ViewBuilder
    private func lockedBar(title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "lock.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.gray.opacity(0.5))
            }
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("—")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.gray.opacity(0.4))
                Text("Pro")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(secondaryColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(red: 1.0, green: 0.87, blue: 0.87))
                    .cornerRadius(6)
            }
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.12))
                .frame(height: 6)
        }
        .padding(20)
        .frame(width: 170)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

// MARK: - ResultBar Struct
struct ResultBar: View {
    let title: String
    let score: Double
    let icon: String
    let color: Color
    
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(primaryText)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(score))")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(color)
                
                Text("/100")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * (score / 100), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .frame(width: 170)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ResultView(record: nil, isFromRecents: true)
}
