import SwiftUI
import RevenueCat

struct MoreView: View {
    @StateObject private var vm = MoreViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showEditProfile = false
    @State private var showUpgrade = false
    @State private var showDeleteConfirm = false
    @State private var isRestoring = false
    @State private var restoreMessage: String?

    private var isPremium: Bool { subscriptionManager.isPremium }

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("profile", comment: ""))
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.brandText)

                            Text(NSLocalizedString("manage_information", comment: ""))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { showEditProfile = true }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.brandPrimary)
                                .cornerRadius(Radius.card)
                        }
                        .accessibilityLabel(Text(AppStrings.editProfile))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    HStack {
                        Spacer()
                        BrandCircleIcon(systemImage: "person.fill", size: 130)
                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("personal_information", comment: ""))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.brandText)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            Button { showEditProfile = true } label: { InfoCard(label: AppStrings.fullName, value: vm.userName) }
                                .buttonStyle(.plain)
                            Button { showEditProfile = true } label: { InfoCard(label: AppStrings.age, value: vm.userAge) }
                                .buttonStyle(.plain)
                            Button { showEditProfile = true } label: { InfoCard(label: AppStrings.gender, value: vm.userGender) }
                                .buttonStyle(.plain)
                            Button { showEditProfile = true } label: { InfoCard(label: AppStrings.skinType, value: vm.userSkinType) }
                                .buttonStyle(.plain)
                        }
                    }
                    
                    if isPremium {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 52, height: 52)

                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(NSLocalizedString("premium_active", comment: ""))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(NSLocalizedString("all_features_unlocked", comment: ""))
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                }

                                Spacer()

                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            Divider()
                                .background(Color.white.opacity(0.3))

                            VStack(alignment: .leading, spacing: 10) {
                                PremiumCardRow(text: AppStrings.unlimitedSkinAnalyses)
                                PremiumCardRow(text: AppStrings.advancedAIInsights)
                                PremiumCardRow(text: AppStrings.personalizedRecommendations)
                                PremiumCardRow(text: AppStrings.fullHistoryProgressTracking)
                            }
                        }
                        .padding(24)
                        .background(Color.brandPrimary)
                        .cornerRadius(Radius.card)
                        .padding(.horizontal, 20)
                        .cardShadow()
                    } else {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Radius.card)
                                        .fill(Color.brandBackground)
                                        .frame(width: 48, height: 48)

                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.brandPrimary)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(NSLocalizedString("go_premium", comment: ""))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(NSLocalizedString("unlock_advanced_features", comment: ""))
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                PremiumCardRow(text: AppStrings.unlimitedSkinAnalyses)
                                PremiumCardRow(text: AppStrings.advancedAIInsights)
                                PremiumCardRow(text: AppStrings.personalizedRecommendations)
                                PremiumCardRow(text: AppStrings.fullHistoryProgressTracking)
                            }

                            Button(action: { showUpgrade = true }) {
                                Text(NSLocalizedString("upgrade_now", comment: ""))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.brandPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color.white)
                                    .cornerRadius(Radius.card)
                            }
                            .padding(.top, 10)
                        }
                        .padding(24)
                        .background(Color.brandPrimary)
                        .cornerRadius(Radius.card)
                        .padding(.horizontal, 20)
                        .cardShadow()
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("settings", comment: ""))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.brandText)
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            Button { restorePurchases() } label: {
                                SettingsRow(
                                    icon: "arrow.clockwise",
                                    title: NSLocalizedString("restore_purchases", comment: ""),
                                    showsProgress: isRestoring
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(isRestoring)

                            Button { showDeleteConfirm = true } label: {
                                SettingsRow(
                                    icon: "trash",
                                    title: NSLocalizedString("delete_all_data", comment: ""),
                                    isDestructive: true
                                )
                            }
                            .buttonStyle(.plain)

                            SettingsRow(
                                icon: "info.circle",
                                title: NSLocalizedString("version", comment: ""),
                                value: appVersion,
                                showsChevron: false
                            )
                        }

                        HStack {
                            Spacer()
                            LegalFooter()
                            Spacer()
                        }
                        .padding(.top, 4)
                    }

                    Color.clear.frame(height: 20)
                }
            }
        }
        .alert(NSLocalizedString("delete_all_data", comment: ""), isPresented: $showDeleteConfirm) {
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            Button(NSLocalizedString("delete", comment: ""), role: .destructive) {
                LocalPersistenceManager.shared.deleteAllUserData()
                vm.loadProfile()
            }
        } message: {
            Text(NSLocalizedString("delete_all_data_message", comment: ""))
        }
        .alert(NSLocalizedString("restore_purchases", comment: ""), isPresented: Binding(
            get: { restoreMessage != nil },
            set: { if !$0 { restoreMessage = nil } }
        )) {
            Button(NSLocalizedString("ok", comment: "")) { restoreMessage = nil }
        } message: {
            Text(restoreMessage ?? "")
        }
        .sheet(isPresented: $showEditProfile, onDismiss: { vm.loadProfile() }) {
            ProfileEditSheet()
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeSheetView()
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    }

    private func restorePurchases() {
        isRestoring = true
        Purchases.shared.restorePurchases { info, error in
            DispatchQueue.main.async {
                isRestoring = false
                if let error = error {
                    restoreMessage = String(format: NSLocalizedString("purchase_error_restore_failed_%@", comment: ""), error.localizedDescription)
                    return
                }
                if info?.entitlements["pro"]?.isActive == true {
                    SubscriptionManager.shared.isPremium = true
                } else {
                    restoreMessage = NSLocalizedString("restore_no_subscription", comment: "")
                }
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var isDestructive: Bool = false
    var showsChevron: Bool = true
    var showsProgress: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isDestructive ? .brandNegative : .brandPrimary)
                .frame(width: 24)
                .accessibilityHidden(true)

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isDestructive ? .brandNegative : .brandText)

            Spacer()

            if showsProgress {
                ProgressView()
            } else if let value {
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
            } else if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray.opacity(0.5))
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
        .padding(.horizontal, 20)
    }
}

struct ProfileEditSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var age: Int = 25
    @State private var gender: Gender? = nil
    @State private var skinType: SkinType? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            fieldLabel(AppStrings.fullName)
                            TextField(AppStrings.fullName, text: $name)
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(Radius.card)
                                .cardShadow()
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            fieldLabel(AppStrings.age)
                            HStack(spacing: 16) {
                                Slider(
                                    value: Binding(
                                        get: { Double(age) },
                                        set: { age = Int($0) }
                                    ),
                                    in: 13...80,
                                    step: 1
                                )
                                .tint(Color.brandPrimary)

                                Text("\(age)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.brandText)
                                    .frame(minWidth: 34)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(Radius.card)
                            .cardShadow()
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            fieldLabel(AppStrings.gender)
                            VStack(spacing: 10) {
                                ForEach(Gender.allCases, id: \.self) { option in
                                    selectionRow(title: option.localizedTitle, isSelected: gender == option) {
                                        gender = option
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            fieldLabel(AppStrings.skinType)
                            VStack(spacing: 10) {
                                ForEach(SkinType.allCases, id: \.self) { option in
                                    selectionRow(title: option.localizedTitle, isSelected: skinType == option) {
                                        skinType = option
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(AppStrings.editProfile)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.cancel) { dismiss() }
                        .foregroundColor(.brandPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppStrings.save) {
                        // Same contract as ProfileSetupViewModel.completeProfile():
                        // enum raw values keep ScoringEngine and RoutineEngine lookups intact.
                        LocalPersistenceManager.shared.saveUserProfile(
                            name: name,
                            skinType: skinType?.rawValue ?? "Normal",
                            ageRange: String(age),
                            gender: gender?.rawValue ?? "Prefer not to say",
                            knownIssues: ""
                        )
                        dismiss()
                    }
                    .foregroundColor(.brandPrimary)
                    .fontWeight(.bold)
                }
            }
        }
        .onAppear {
            let profile = LocalPersistenceManager.shared.fetchUserProfile()
            name     = profile?.name ?? ""
            age      = profile?.ageRange.flatMap(Int.init) ?? 25
            gender   = profile?.gender.flatMap(Gender.init(rawValue:))
            skinType = profile?.skinType.flatMap(SkinType.init(rawValue:))
        }
    }

    @ViewBuilder
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.gray)
    }

    @ViewBuilder
    private func selectionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundColor(isSelected ? .white : .brandText)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? Color.brandPrimary : Color.white)
            .cornerRadius(Radius.card)
            .cardShadow()
        }
        .buttonStyle(.plain)
    }
}

struct PremiumCardRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct InfoCard: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.brandText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
        .padding(.horizontal, 20)
    }
}

#Preview {
    MoreView()
}
