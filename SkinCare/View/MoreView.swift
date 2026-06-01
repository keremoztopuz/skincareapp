import SwiftUI

struct MoreView: View {
    @StateObject private var vm = MoreViewModel()
    @AppStorage("isPremium") private var isPremium = false
    @State private var showEditProfile = false
    @State private var showUpgrade = false

    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
        let outerColor = Color(red: 1.0, green: 0.87, blue: 0.87)
        
        ZStack {
            mainColor.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("profile", comment: ""))
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(primaryText)
                            
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
                                .background(secondaryColor)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(outerColor)
                                .frame(width: 130, height: 130)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            
                            Circle()
                                .fill(secondaryColor)
                                .frame(width: 90, height: 90)
                                .shadow(color: secondaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("personal_information", comment: ""))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(primaryText)
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
                                ActiveFeatureRow(text: AppStrings.unlimitedSkinAnalyses)
                                ActiveFeatureRow(text: AppStrings.advancedAIInsights)
                                ActiveFeatureRow(text: AppStrings.personalizedRecommendations)
                                ActiveFeatureRow(text: AppStrings.fullHistoryProgressTracking)
                            }
                        }
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [secondaryColor, secondaryColor.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(25)
                        .padding(.horizontal, 20)
                        .shadow(color: secondaryColor.opacity(0.3), radius: 15, x: 0, y: 8)
                    } else {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(mainColor)
                                        .frame(width: 48, height: 48)

                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(secondaryColor)
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
                                PremiumFeatureRow(text: AppStrings.unlimitedSkinAnalyses)
                                PremiumFeatureRow(text: AppStrings.advancedAIInsights)
                                PremiumFeatureRow(text: AppStrings.personalizedRecommendations)
                                PremiumFeatureRow(text: AppStrings.fullHistoryProgressTracking)
                            }

                            Button(action: { showUpgrade = true }) {
                                Text(NSLocalizedString("upgrade_now", comment: ""))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(secondaryColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            }
                            .padding(.top, 10)
                        }
                        .padding(24)
                        .background(secondaryColor)
                        .cornerRadius(25)
                        .padding(.horizontal, 20)
                        .shadow(color: secondaryColor.opacity(0.3), radius: 15, x: 0, y: 8)
                    }

                    Color.clear.frame(height: 20)
                }
            }
        }
        .sheet(isPresented: $showEditProfile, onDismiss: { vm.loadProfile() }) {
            ProfileEditSheet()
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeSheetView()
        }
    }
}

struct ProfileEditSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var gender: String = ""
    @State private var skinType: String = ""

    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let primaryText    = Color(red: 0.1,  green: 0.1,  blue: 0.2)
    let mainColor      = Color(red: 1.0,  green: 0.97, blue: 0.97)

    var body: some View {
        NavigationStack {
            ZStack {
                mainColor.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        editField(label: AppStrings.fullName,  text: $name)
                        editField(label: AppStrings.ageRange,  text: $age)
                        editField(label: AppStrings.gender,    text: $gender)
                        editField(label: AppStrings.skinType,  text: $skinType)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(AppStrings.editProfile)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.cancel) { dismiss() }
                        .foregroundColor(secondaryColor)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppStrings.save) {
                        LocalPersistenceManager.shared.saveUserProfile(
                            name: name, skinType: skinType,
                            ageRange: age, gender: gender, knownIssues: ""
                        )
                        dismiss()
                    }
                    .foregroundColor(secondaryColor)
                    .fontWeight(.bold)
                }
            }
        }
        .onAppear {
            let profile = LocalPersistenceManager.shared.fetchUserProfile()
            name     = profile?.name      ?? ""
            age      = profile?.ageRange  ?? ""
            gender   = profile?.gender    ?? ""
            skinType = profile?.skinType  ?? ""
        }
    }

    @ViewBuilder
    private func editField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
            TextField(label, text: text)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
        }
    }
}

struct ActiveFeatureRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.green)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct PremiumFeatureRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct InfoCard: View {
    let label: String
    let value: String
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(primaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

#Preview {
    MoreView()
}
