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
        
        ZStack() {
            mainColor.ignoresSafeArea()
            
            VStack {
                Text("Search")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search Products", text: $vm.searchText)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(vm.filteredProducts) { product in
                            Button(action: {
                                print("\(product.name) clicked.")
                            }) {
                                SearchProductCard(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct SearchProductCard: View {
    let product: Product
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let badgeBg = Color(red: 1.0, green: 0.87, blue: 0.87)
    
    var body: some View {
        
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Text(product.category)
                        .font(.system(size:12, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(badgeBg)
                        .foregroundColor(secondaryColor)
                        .cornerRadius(8)
                }
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size:14))
                    Text("4.8")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    SearchView()
}
