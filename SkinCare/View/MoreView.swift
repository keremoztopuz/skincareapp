import SwiftUI
import RevenueCat

struct MoreView: View {
    @StateObject private var vm = MoreViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showEditProfile = false
    @State private var showUpgrade = false
    @State private var showDeleteConfirm = false
    @State private var showCredits = false
    @State private var showDisclaimer = false
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
                                .font(.scaled(size: 34, weight: .bold))
                                .foregroundColor(.brandText)

                            Text(NSLocalizedString("manage_information", comment: ""))
                                .font(.scaled(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { showEditProfile = true }) {
                            Image(systemName: "pencil")
                                .font(.scaled(size: 18, weight: .bold))
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

                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            StatCard(
                                value: "\(vm.totalAnalyses)",
                                label: NSLocalizedString("stat_total_analyses", comment: "")
                            )
                            StatCard(
                                value: vm.latestScore.map(String.init) ?? "-",
                                label: NSLocalizedString("stat_latest_score", comment: "")
                            )
                            StatCard(
                                value: vm.memberSince,
                                label: NSLocalizedString("stat_member_since", comment: "")
                            )
                        }

                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.brandBlush)
                                    .frame(width: 48, height: 48)
                                Image(systemName: "flame.fill")
                                    .font(.scaled(size: 22))
                                    .foregroundColor(.brandPrimary)
                                    .accessibilityHidden(true)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(format: NSLocalizedString("routine_streak_days_%lld", comment: ""), vm.routineStreak))
                                    .font(.scaled(size: 18, weight: .bold))
                                    .foregroundColor(.brandText)
                                Text(NSLocalizedString("routine_streak", comment: ""))
                                    .font(.scaled(size: 13))
                                    .foregroundColor(.gray)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(Radius.card)
                        .cardShadow()
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("personal_information", comment: ""))
                            .font(.scaled(size: 18, weight: .bold))
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
                                        .font(.scaled(size: 24))
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(NSLocalizedString("premium_active", comment: ""))
                                        .font(.scaled(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(NSLocalizedString("all_features_unlocked", comment: ""))
                                        .font(.scaled(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                }

                                Spacer()

                                Image(systemName: "checkmark.seal.fill")
                                    .font(.scaled(size: 28))
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
                                        .font(.scaled(size: 22))
                                        .foregroundColor(.brandPrimary)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(NSLocalizedString("go_premium", comment: ""))
                                        .font(.scaled(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(NSLocalizedString("unlock_advanced_features", comment: ""))
                                        .font(.scaled(size: 14))
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
                                    .font(.scaled(size: 16, weight: .bold))
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
                            .font(.scaled(size: 18, weight: .bold))
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

                            Button { showCredits = true } label: {
                                SettingsRow(
                                    icon: "text.book.closed",
                                    title: NSLocalizedString("credits", comment: "")
                                )
                            }
                            .buttonStyle(.plain)

                            // The medical notice, the terms and the privacy
                            // policy each get their own row: they used to be a
                            // consent screen and a pair of 12pt footer links,
                            // neither of which reads as something you can go
                            // back and check.
                            Button { showDisclaimer = true } label: {
                                SettingsRow(
                                    icon: "exclamationmark.triangle",
                                    title: NSLocalizedString("important_notice", comment: "")
                                )
                            }
                            .buttonStyle(.plain)

                            Link(destination: LegalURLs.terms) {
                                SettingsRow(
                                    icon: "doc.text",
                                    title: NSLocalizedString("terms_of_use", comment: "")
                                )
                            }
                            .buttonStyle(.plain)

                            Link(destination: LegalURLs.privacy) {
                                SettingsRow(
                                    icon: "hand.raised",
                                    title: NSLocalizedString("privacy_policy", comment: "")
                                )
                            }
                            .buttonStyle(.plain)

                            // Last, and on its own: the only destructive row
                            // on the screen should not sit between two
                            // harmless ones.
                            Button { showDeleteConfirm = true } label: {
                                SettingsRow(
                                    icon: "trash",
                                    title: NSLocalizedString("delete_all_data", comment: ""),
                                    isDestructive: true
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        HStack {
                            Spacer()
                            Text(appVersion)
                                .font(.scaled(size: 12))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.top, 8)
                    }

                    Color.clear.frame(height: 20)
                }
            }
        }
        .alert(NSLocalizedString("delete_all_data", comment: ""), isPresented: $showDeleteConfirm) {
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            Button(NSLocalizedString("delete", comment: ""), role: .destructive) {
                LocalPersistenceManager.shared.deleteAllUserData()
                // User-generated state outside Core Data goes too. The scan
                // quota deliberately stays: it is a billing control, and
                // clearing it would turn "delete my data" into a free-scan
                // reset.
                RoutineCompletionStore.shared.removeAll()
                UserDefaults.standard.removeObject(forKey: "hasSeenCameraGuide")
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
        .sheet(isPresented: $showCredits) {
            CreditsView()
        }
        .sheet(isPresented: $showDisclaimer) {
            DisclaimerView()
        }
        .onAppear {
            vm.loadProfile()
        }
    }

    /// "Skinner 1.0 (2)" — the marketing version plus the build, because a
    /// bug report that names only "1.0" cannot be matched to a TestFlight build.
    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let name = info?["CFBundleDisplayName"] as? String
            ?? info?["CFBundleName"] as? String
            ?? "Skinner"
        let short = info?["CFBundleShortVersionString"] as? String ?? "-"
        let build = info?["CFBundleVersion"] as? String
        return build.map { "\(name) \(short) (\($0))" } ?? "\(name) \(short)"
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
                if info?.entitlements[SubscriptionManager.proEntitlementID]?.isActive == true {
                    SubscriptionManager.shared.isPremium = true
                    restoreMessage = NSLocalizedString("restore_success", comment: "")
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
                .font(.scaled(size: 16, weight: .semibold))
                .foregroundColor(isDestructive ? .brandNegative : .brandPrimary)
                .frame(width: 24)
                .accessibilityHidden(true)

            Text(title)
                .font(.scaled(size: 16, weight: .semibold))
                .foregroundColor(isDestructive ? .brandNegative : .brandText)

            Spacer()

            if showsProgress {
                // An action in flight, not content arriving: a spinner is the
                // right indicator here, so it only picks up the brand tint.
                ProgressView()
                    .tint(.brandPrimary)
            } else if let value {
                Text(value)
                    .font(.scaled(size: 15, weight: .medium))
                    .foregroundColor(.gray)
            } else if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.scaled(size: 14, weight: .bold))
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
                                .font(.scaled(size: 16))
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
                                    .font(.scaled(size: 18, weight: .bold))
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
                        // knownIssues is not edited here, so carry the stored
                        // value through instead of wiping it on every save.
                        let existingIssues = LocalPersistenceManager.shared.fetchUserProfile()?.knownIssues ?? ""
                        LocalPersistenceManager.shared.saveUserProfile(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            skinType: skinType?.rawValue ?? "Normal",
                            ageRange: String(age),
                            gender: gender?.rawValue ?? "Prefer not to say",
                            knownIssues: existingIssues
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
            .font(.scaled(size: 13, weight: .medium))
            .foregroundColor(.gray)
    }

    @ViewBuilder
    private func selectionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.scaled(size: 16, weight: .semibold))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.scaled(size: 14, weight: .bold))
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
                .font(.scaled(size: 14, weight: .medium))
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
                    .font(.scaled(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.scaled(size: 16, weight: .bold))
                    .foregroundColor(.brandText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.scaled(size: 14, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
        .padding(.horizontal, 20)
    }
}

/// Deliberately iconless. Three symbols side by side read as decoration
/// rather than information; the number is the content and the label already
/// says which number it is. The streak card keeps its flame because there the
/// symbol is the only thing distinguishing it from a plain count.
struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.scaled(size: 17, weight: .bold))
                .foregroundColor(.brandText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.scaled(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
    }
}

#Preview {
    MoreView()
}
