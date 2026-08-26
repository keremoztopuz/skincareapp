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
        NavigationStack {
        ZStack() {
            Color.brandBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("search", comment: ""))
                        .font(.scaled(size: 34, weight: .bold))
                        .foregroundColor(.brandText)

                    Text(NSLocalizedString("find_best_products", comment: ""))
                        .font(.scaled(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.brandPrimary)
                        .font(.scaled(size: 18, weight: .bold))

                    TextField(NSLocalizedString("search_products", comment: ""), text: $vm.searchText)
                        .font(.scaled(size: 16))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(Color.white)
                .cornerRadius(Radius.card)
                .cardShadow()
                .padding(.horizontal, 20)

                if vm.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(.brandPrimary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else if vm.loadFailed {
                    // A failed fetch is not "no products": say so and offer
                    // a retry, or the tab stays empty until the app restarts.
                    VStack(spacing: 16) {
                        Spacer()
                        BrandCircleIcon(systemImage: vm.loadErrorMessage == AppStrings.internetConnectionRequired
                                        ? "wifi.slash"
                                        : "exclamationmark.icloud", size: 120)
                        Text(vm.loadErrorMessage)
                            .font(.scaled(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Button {
                            Task { await vm.fetchProducts() }
                        } label: {
                            Text(NSLocalizedString("try_again", comment: ""))
                                .font(.scaled(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.brandPrimary)
                                .cornerRadius(Radius.card)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else if vm.filteredProducts.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        BrandCircleIcon(systemImage: "magnifyingglass", size: 120)
                        // An empty catalogue is a success with zero rows,
                        // not a failure — the failure branch is above.
                        Text(vm.searchText.isEmpty
                             ? AppStrings.catalogEmpty
                             : NSLocalizedString("search_no_results", comment: ""))
                            .font(.scaled(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
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
        }
        } // NavigationStack
    }
}

struct SearchProductCard: View {
    let product: Product

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.small)
                    .fill(Color.brandPrimary.opacity(0.05))
                    .frame(width: 60, height: 60)

                if let urlString = product.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                } else {
                    Image(systemName: "bottle.condiment.fill")
                        .foregroundColor(Color.brandPrimary.opacity(0.2))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.scaled(size: 16, weight: .bold))
                    .foregroundColor(.brandText)
                    .lineLimit(1)

                Text(product.brand ?? AppStrings.unknownBrand)
                    .font(.scaled(size: 12, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.brandBlush)
                    .foregroundColor(.brandPrimary)
                    .cornerRadius(Radius.small)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.scaled(size: 14, weight: .bold))
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
    }
}

#Preview {
    SearchView()
}
