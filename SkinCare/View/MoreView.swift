import SwiftUI

struct MoreView: View {
    @StateObject private var vm = MoreViewModel()
    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue:
          0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11,
          blue: 0.17)
        let outerColor = Color(red: 1.0, green: 0.87, blue: 0.87)
        
        ZStack {
            mainColor.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text("Profile")
                                .font(.system(size: 28, weight: .bold))
                            
                            Text("Manage your information")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "pencil")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
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
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .fill(secondaryColor)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    
                    Text("Personal Information")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 20)
                    
                    InfoCard(label: "Name", value: vm.userName)
                    InfoCard(label: "Age", value: vm.userAge)
                    InfoCard(label: "Gender", value: vm.userGender)
                    InfoCard(label: "Skintype", value: vm.userSkinType)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 22))
                                .foregroundColor(secondaryColor)
                                .frame(width: 44, height: 44)
                                .background(outerColor)
                                .cornerRadius(12)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Go Premium")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Unlock all features")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Unlimited skin analyses")
                            Text("• Advanced AI insights")
                            Text("• Personalized recommendations")
                            Text("• Full history & progress tracking")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))

                        Button(action: {}) {
                            Text("Upgrade Now")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(secondaryColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(mainColor)
                                .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(secondaryColor)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)

                    Color.clear.frame(height: 20)
                                        
                }
            }
        }
    }
}

struct InfoCard: View {
      let label: String
      let value: String

      var body: some View {
          VStack(alignment: .leading, spacing: 6) {
              Text(label)
                  .font(.system(size: 14))
                  .foregroundColor(.gray)
              Text(value)
                  .font(.system(size: 18, weight: .semibold))
                  .foregroundColor(Color(red: 0.1, green: 0.1,
   blue: 0.2))
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(16)
          .background(Color.white)
          .cornerRadius(12)
          .shadow(color: Color.black.opacity(0.04), radius: 4,
   x: 0, y: 2)
          .padding(.horizontal, 20)
      }
  }

#Preview {
    MoreView()
}
