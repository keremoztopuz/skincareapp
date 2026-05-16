import SwiftUI
import AVFoundation
import Lottie
internal import Combine

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @Binding var selectedTab: Int
    
    let routineInfo = (
        title: "Morning Routine",
        icon: "sun.max.fill",
        description: "Focus on hydration and protection. Apply a gentle cleanser followed by a vitamin C serum and SPF 30+.",
        products: ["Cleanser", "Vitamin C", "SPF 30"]
    )
    
    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 18 { return "Good Afternoon" }
        return "Good Evening"
    }
    
    // MARK: Main View
    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
        let outerColor = Color(red: 1.0, green: 0.87, blue: 0.87)
        
        NavigationStack {
            ZStack {
                mainColor.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // greeting Section
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(greetingText), \(vm.userName)")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(primaryText)
                            
                            Text("Let's take care of your skin today")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // analysis Button
                        Button(action: {
                            selectedTab = 2
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(outerColor)
                                    .frame(height: 230)
                                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                                
                                Circle()
                                    .fill(secondaryColor)
                                    .frame(width: 150, height: 150)
                                    .overlay {
                                        VStack(spacing: -18) {
                                            LottieView(animation: .named("Star loader UI"))
                                                .playing(loopMode: .loop)
                                                .configure { animationView in
                                                    let white = ColorValueProvider(UIColor.white.lottieColorValue)
                                                    animationView.setValueProvider(white, keypath: AnimationKeypath(keypath: "**.Color"))
                                                }
                                                .frame(width: 90, height: 90)
                                                .padding(.leading, 10)
                                                .padding(.top, -12)
                                            
                                            Text("Skin analysis")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16, weight: .bold))
                                                .padding(.top, 15)
                                        }
                                    }
                                    .shadow(color: secondaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // skin health grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Skin Health (Avg.)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(primaryText)
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    MetricCard(value: "\(vm.avgOverallScore)", label: "Overall Score")
                                    MetricCard(value: "\(vm.avgDryness)%", label: "Dryness")
                                }
                                HStack(spacing: 12) {
                                    MetricCard(value: "\(vm.avgOiliness)%", label: "Oiliness")
                                    MetricCard(value: "\(vm.avgInflammation)%", label: "Inflammation")
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // recommendation card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Today's Recommendations")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(primaryText)
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(secondaryColor)
                                    .frame(maxWidth: .infinity)
                                    .shadow(color: secondaryColor.opacity(0.3), radius: 15, x: 0, y: 8)

                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(routineInfo.title)
                                            .font(.system(size: 24, weight: .bold))
                                        Spacer()
                                        Image(systemName: routineInfo.icon)
                                            .font(.system(size: 24))
                                    }
                                    
                                    Text(routineInfo.description)
                                        .font(.system(size: 16, weight: .medium))
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .opacity(0.9)
                                    
                                    HStack(spacing: 8) {
                                        ForEach(routineInfo.products, id: \.self) { product in
                                            Text(product)
                                                .font(.system(size: 14, weight: .semibold))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color.white.opacity(0.15))
                                                .cornerRadius(12)
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                                .foregroundColor(.white)
                                .padding(24)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // products horizontal list
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recommended Products")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(primaryText)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(vm.products) { product in
                                        NavigationLink(destination: DetailView(type: .product(product))) {
                                            ProductCard(product: product)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // news horizontal list
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Latest News")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(primaryText)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack(spacing: 16) {
                                    ForEach(vm.news) { news in
                                        NavigationLink(destination: DetailView(type: .news(news))) {
                                            NewsCard(news: news)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // bottom spacing
                        Color.clear.frame(height: 20)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
struct MetricCard: View {
    let value: String
    let label: String
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(secondaryColor)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 90)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct ProductCard: View {
    let product: Product
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                Image(systemName: "face.smiling") // Placeholder
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.47, green: 0.11, blue: 0.17).opacity(0.2))
            }
            .frame(width: 160, height: 160)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(primaryText)
                    .lineLimit(1)
                
                Text(product.category)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 160)
    }
}

struct NewsCard: View {
    let news: News
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .frame(width: 280, height: 180)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .overlay {
                    Image(systemName: "newspaper.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.47, green: 0.11, blue: 0.17).opacity(0.1))
                }
            
            VStack(alignment: .leading, spacing: 4){
                Text(news.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(primaryText)
                    .lineLimit(1)
                
                Text(news.content)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 280)
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
