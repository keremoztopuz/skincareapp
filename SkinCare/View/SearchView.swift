//
//  Search.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()

    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)

        NavigationStack {
        ZStack() {
            mainColor.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Search")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(primaryText)
                    
                    Text("Find the best products for your skin")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(secondaryColor)
                        .font(.system(size: 18, weight: .bold))
                    
                    TextField("Search Products", text: $vm.searchText)
                        .font(.system(size: 16))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(vm.filteredProducts) { product in
                            NavigationLink(destination: DetailView(type: .product(product))) {
                                SearchProductCard(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
        }
        } // NavigationStack
    }
}

struct SearchProductCard: View {
    let product: Product
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    let badgeBg = Color(red: 1.0, green: 0.87, blue: 0.87)
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(secondaryColor.opacity(0.05))
                    .frame(width: 60, height: 60)
                
                if let urlString = product.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "bottle.condiment.fill")
                        .foregroundColor(secondaryColor.opacity(0.2))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(primaryText)
                    .lineLimit(1)
                
                Text(product.brand ?? "Unknown Brand")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeBg)
                    .foregroundColor(secondaryColor)
                    .cornerRadius(6)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    SearchView()
}
