import SwiftUI

struct RoutineView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = RoutineViewModel()
    @State private var showUpgrade = false
    @State private var selectedProduct: Product? = nil
    @State private var showProductDetail = false
    @Binding var selectedTab: Int

    private var isPremium: Bool { SubscriptionManager.shared.isPremium }

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            if !isPremium {
                premiumLockedView
            } else {
                routineContent
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showUpgrade) { UpgradeSheetView() }
        .sheet(isPresented: $vm.showAddProduct) {
            ProductPickerSheet(
                productType: vm.addingProductType,
                routineTime: vm.selectedRoutineTime,
                stepOrder: vm.addingStepOrder
            ) { product in
                vm.addProductManually(
                    product: product,
                    routineTime: vm.selectedRoutineTime,
                    stepOrder: vm.addingStepOrder
                )
            }
        }
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                NavigationStack {
                    DetailView(type: .product(product))
                }
            }
        }
    }

    // MARK: - Routine Content

    private var routineContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                BackHeaderBar(title: NSLocalizedString("your_routine", comment: "")) { dismiss() }

                if !vm.pendingSuggestions.isEmpty {
                    suggestionBanner
                }

                routineTimePicker

                stepsList

                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
    }

    // MARK: - Time Picker

    private var routineTimePicker: some View {
        HStack(spacing: 0) {
            timeButton(title: NSLocalizedString("morning", comment: ""), icon: "sun.max.fill", time: "morning")
            timeButton(title: NSLocalizedString("evening", comment: ""), icon: "moon.fill", time: "evening")
        }
        .background(Color.brandBlush)
        .cornerRadius(Radius.card)
        .padding(.horizontal, 20)
    }

    private func timeButton(title: String, icon: String, time: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                vm.selectedRoutineTime = time
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(vm.selectedRoutineTime == time ? .white : .brandText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(vm.selectedRoutineTime == time ? Color.brandPrimary : Color.clear)
            .cornerRadius(Radius.card)
        }
    }

    // MARK: - Steps List

    private var stepsList: some View {
        VStack(spacing: 16) {
            let items = vm.currentItems
            ForEach(vm.currentSteps, id: \.order) { step in
                let item = items.first(where: { $0.stepOrder == step.order })
                stepCard(step: step, item: item)
            }
        }
        .padding(.horizontal, 20)
    }

    private func stepCard(step: RoutineViewModel.RoutineStep, item: RoutineItem?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: step.icon)
                    .font(.system(size: 14))
                    .foregroundColor(.brandPrimary)
                Text(step.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.brandPrimary)
                Spacer()
                if item != nil {
                    Text(String(format: NSLocalizedString("step_number_%lld", comment: ""), Int(step.order) + 1))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
            }

            if let item = item {
                filledStepContent(item: item, step: step)
            } else {
                emptyStepContent(step: step)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
    }

    private func filledStepContent(item: RoutineItem, step: RoutineViewModel.RoutineStep) -> some View {
        HStack(spacing: 14) {
            if let url = item.productImageUrl, let imageUrl = URL(string: url) {
                AsyncImage(url: imageUrl) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: Radius.small)
                        .fill(Color.brandBlush)
                        .overlay(
                            Image(systemName: step.icon)
                                .foregroundColor(Color.brandPrimary.opacity(0.5))
                        )
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
            } else {
                RoundedRectangle(cornerRadius: Radius.small)
                    .fill(Color.brandBlush)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: step.icon)
                            .foregroundColor(Color.brandPrimary.opacity(0.5))
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.productName ?? AppStrings.unknownProduct)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.brandText)
                    .lineLimit(1)
                if let brand = item.productBrand {
                    Text(brand)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button {
                vm.removeItem(item)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .accessibilityLabel(Text(NSLocalizedString("delete", comment: "")))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let productId = item.productId {
                selectedProduct = Product(
                    id: productId,
                    name: item.productName ?? "",
                    brand: item.productBrand,
                    description: nil,
                    imageUrl: item.productImageUrl,
                    productType: item.productType,
                    activeIngredients: nil,
                    usageTime: nil,
                    frequency: nil,
                    contraindications: nil,
                    skinTypes: nil,
                    isActive: true
                )
                showProductDetail = true
            }
        }
    }

    private func emptyStepContent(step: RoutineViewModel.RoutineStep) -> some View {
        Button {
            vm.addingStepOrder = step.order
            vm.addingProductType = step.productTypes.first ?? ""
            vm.showAddProduct = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text(String(format: NSLocalizedString("add_product_type_%@", comment: ""), step.label))
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(Color.brandPrimary.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: Radius.card)
                    .strokeBorder(Color.brandPrimary.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [8, 4]))
            )
        }
    }

    // MARK: - Suggestion Banner

    private var suggestionBanner: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.brandPrimary)
                Text(NSLocalizedString("new_recommendations", comment: ""))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.brandText)
                Spacer()
                Text(String(format: NSLocalizedString("products_count_%lld", comment: ""), vm.pendingSuggestions.count))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.pendingSuggestions, id: \.id) { suggestion in
                        suggestionCard(suggestion)
                    }
                }
            }

            HStack(spacing: 12) {
                Button {
                    withAnimation { vm.acceptAllSuggestions() }
                } label: {
                    Text(NSLocalizedString("accept_all", comment: ""))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.brandPrimary)
                        .cornerRadius(Radius.card)
                }

                Button {
                    withAnimation { vm.dismissAllSuggestions() }
                } label: {
                    Text(NSLocalizedString("dismiss", comment: ""))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.brandBlush)
                        .cornerRadius(Radius.card)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
        .padding(.horizontal, 20)
    }

    private func suggestionCard(_ suggestion: RoutineSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let url = suggestion.productImageUrl, let imageUrl = URL(string: url) {
                AsyncImage(url: imageUrl) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: Radius.small).fill(Color.brandBlush)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
            }
            Text(suggestion.productName ?? "")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.brandText)
                .lineLimit(1)
            Text(AppStrings.localizedRoutineTime(suggestion.routineTime))
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(width: 90)
    }

    // MARK: - Premium Locked

    private var premiumLockedView: some View {
        VStack(spacing: 24) {
            BackHeaderBar(title: NSLocalizedString("your_routine", comment: "")) { dismiss() }

            Spacer()

            BrandCircleIcon(systemImage: "lock.fill", size: 120)

            Text(NSLocalizedString("personalized_routine", comment: ""))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.brandText)

            Text(NSLocalizedString("upgrade_for_routine", comment: ""))
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                showUpgrade = true
            } label: {
                Text(NSLocalizedString("upgrade_to_pro", comment: ""))
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}

// MARK: - Product Picker Sheet

struct ProductPickerSheet: View {
    let productType: String
    let routineTime: String
    let stepOrder: Int16
    let onSelect: (Product) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var products: [Product] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                } else if products.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text(NSLocalizedString("no_products_found", comment: ""))
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(products) { product in
                                Button {
                                    onSelect(product)
                                    dismiss()
                                } label: {
                                    pickerProductCard(product)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle(String(format: NSLocalizedString("choose_product_type_%@", comment: ""), AppStrings.localizedProductType(productType)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel", comment: "")) { dismiss() }
                }
            }
            .task {
                do {
                    products = try await SupabaseService.shared.fetchProductsByType(productType)
                } catch {
                    print("Fetch products by type error: \(error)")
                }
                isLoading = false
            }
        }
    }

    private func pickerProductCard(_ product: Product) -> some View {
        HStack(spacing: 14) {
            if let url = product.imageUrl, let imageUrl = URL(string: url) {
                AsyncImage(url: imageUrl) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: Radius.small)
                        .fill(Color.brandBlush)
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.brandText)
                    .lineLimit(1)
                if let brand = product.brand {
                    Text(brand)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: "plus.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.brandPrimary)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
    }
}

#Preview {
    RoutineView(selectedTab: .constant(0))
}
