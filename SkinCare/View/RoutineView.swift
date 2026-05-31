import SwiftUI

struct RoutineView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = RoutineViewModel()
    @State private var showUpgrade = false
    @State private var selectedProduct: Product? = nil
    @State private var showProductDetail = false
    @Binding var selectedTab: Int

    private var isPremium: Bool { SubscriptionManager.shared.isPremium }

    let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    let outerColor = Color(red: 1.0, green: 0.87, blue: 0.87)

    var body: some View {
        ZStack {
            mainColor.ignoresSafeArea()

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

                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(secondaryColor)
                            .clipShape(Circle())
                            .shadow(color: secondaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    Spacer()
                    Text(NSLocalizedString("your_routine", comment: ""))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(primaryText)
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

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
        .background(outerColor)
        .cornerRadius(16)
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
            .foregroundColor(vm.selectedRoutineTime == time ? .white : primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(vm.selectedRoutineTime == time ? secondaryColor : Color.clear)
            .cornerRadius(16)
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
                    .foregroundColor(secondaryColor)
                Text(step.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(secondaryColor)
                Spacer()
                if item != nil {
                    Text("Step \(step.order + 1)")
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
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private func filledStepContent(item: RoutineItem, step: RoutineViewModel.RoutineStep) -> some View {
        HStack(spacing: 14) {
            if let url = item.productImageUrl, let imageUrl = URL(string: url) {
                AsyncImage(url: imageUrl) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(outerColor)
                        .overlay(
                            Image(systemName: step.icon)
                                .foregroundColor(secondaryColor.opacity(0.5))
                        )
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(outerColor)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: step.icon)
                            .foregroundColor(secondaryColor.opacity(0.5))
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.productName ?? "Unknown Product")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryText)
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
                Text("Add \(step.label)")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(secondaryColor.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(secondaryColor.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [8, 4]))
            )
        }
    }

    // MARK: - Suggestion Banner

    private var suggestionBanner: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(secondaryColor)
                Text(NSLocalizedString("new_recommendations", comment: ""))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(primaryText)
                Spacer()
                Text("\(vm.pendingSuggestions.count) products")
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
                        .background(secondaryColor)
                        .cornerRadius(12)
                }

                Button {
                    withAnimation { vm.dismissAllSuggestions() }
                } label: {
                    Text(NSLocalizedString("dismiss", comment: ""))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(secondaryColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(outerColor)
                        .cornerRadius(12)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }

    private func suggestionCard(_ suggestion: RoutineSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let url = suggestion.productImageUrl, let imageUrl = URL(string: url) {
                AsyncImage(url: imageUrl) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 10).fill(outerColor)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Text(suggestion.productName ?? "")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(primaryText)
                .lineLimit(1)
            Text(suggestion.routineTime?.capitalized ?? "")
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(width: 90)
    }

    // MARK: - Premium Locked

    private var premiumLockedView: some View {
        VStack(spacing: 24) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(secondaryColor)
                        .clipShape(Circle())
                        .shadow(color: secondaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                Spacer()
                Text(NSLocalizedString("your_routine", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(primaryText)
                Spacer()
                Circle().fill(Color.clear).frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()

            ZStack {
                Circle()
                    .fill(outerColor)
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(secondaryColor)
                    .frame(width: 80, height: 80)
                Image(systemName: "lock.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }

            Text(NSLocalizedString("personalized_routine", comment: ""))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(primaryText)

            Text(NSLocalizedString("upgrade_for_routine", comment: ""))
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                showUpgrade = true
            } label: {
                Text(NSLocalizedString("upgrade_to_pro", comment: ""))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(secondaryColor)
                    .cornerRadius(20)
                    .shadow(color: secondaryColor.opacity(0.3), radius: 10, x: 0, y: 8)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Empty State (no analysis yet)

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

    let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)

    var body: some View {
        NavigationStack {
            ZStack {
                mainColor.ignoresSafeArea()

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
            .navigationTitle("Choose \(productType.replacingOccurrences(of: "_", with: " ").capitalized)")
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
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 1.0, green: 0.87, blue: 0.87))
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(primaryText)
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
                .foregroundColor(secondaryColor)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    RoutineView(selectedTab: .constant(0))
}
