import SwiftUI
import AVFoundation
import Lottie
internal import Combine

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @Binding var selectedTab: Int
    
    var routineTitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 18 ? NSLocalizedString("morning_routine", comment: "") : NSLocalizedString("evening_routine", comment: "")
    }

    var routineIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 18 ? "sun.max.fill" : "moon.fill"
    }

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return NSLocalizedString("good_morning", comment: "") }
        if hour < 18 { return NSLocalizedString("good_afternoon", comment: "") }
        return NSLocalizedString("good_evening", comment: "")
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
                            
                            Text(NSLocalizedString("lets_take_care", comment: ""))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        if let error = vm.errorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "wifi.slash")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                                Text(error)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Button("Try Again") {
                                    Task { await vm.fetchAllCloudData() }
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(secondaryColor)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                        
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
                                            LottieView(animation: .named("AI Star loader UI"))
                                                .playing(loopMode: .loop)
                                                .configure { animationView in
                                                    let white = ColorValueProvider(UIColor.white.lottieColorValue)
                                                    animationView.setValueProvider(white, keypath: AnimationKeypath(keypath: "**.Color"))
                                                }
                                                .frame(width: 90, height: 90)
                                                .padding(.leading, 10)
                                                .padding(.top, -12)
                                            
                                            Text(NSLocalizedString("skin_analysis", comment: ""))
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
                            Text(NSLocalizedString("your_skin_health_avg", comment: ""))
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
                        
                        // routine card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(NSLocalizedString("your_routine", comment: ""))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(primaryText)
                                if vm.hasPendingSuggestions {
                                    Circle()
                                        .fill(secondaryColor)
                                        .frame(width: 8, height: 8)
                                }
                            }

                            NavigationLink(destination: RoutineView(selectedTab: $selectedTab)) {
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(secondaryColor)
                                        .frame(maxWidth: .infinity)
                                        .shadow(color: secondaryColor.opacity(0.3), radius: 15, x: 0, y: 8)

                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text(routineTitle)
                                                .font(.system(size: 24, weight: .bold))
                                            Spacer()
                                            Image(systemName: routineIcon)
                                                .font(.system(size: 24))
                                        }

                                        if vm.routineItemCount > 0 {
                                            Text(String(format: NSLocalizedString("steps_configured_%lld", comment: ""), vm.routineItemCount))
                                                .font(.system(size: 16, weight: .medium))
                                                .opacity(0.9)

                                            HStack(spacing: 8) {
                                                ForEach(vm.routineStepNames, id: \.self) { name in
                                                    Text(name)
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 8)
                                                        .background(Color.white.opacity(0.15))
                                                        .cornerRadius(12)
                                                }
                                            }
                                            .padding(.top, 4)
                                        } else {
                                            Text(NSLocalizedString("tap_to_setup_routine", comment: ""))
                                                .font(.system(size: 16, weight: .medium))
                                                .multilineTextAlignment(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .opacity(0.9)
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .padding(24)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        
                        // products horizontal list
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("recommended_products", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(primaryText)
                                .padding(.horizontal, 20)

                            if vm.isLoading && vm.products.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(0..<3, id: \.self) { _ in
                                            VStack(alignment: .leading, spacing: 12) {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(outerColor)
                                                    .frame(width: 160, height: 160)
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(outerColor)
                                                    .frame(width: 120, height: 14)
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(outerColor.opacity(0.6))
                                                    .frame(width: 80, height: 12)
                                            }
                                            .frame(width: 160)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            } else {
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
                        }

                        // articles horizontal list
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("latest_articles", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(primaryText)
                                .padding(.horizontal, 20)

                            if vm.isLoading && vm.articles.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(0..<2, id: \.self) { _ in
                                            VStack(alignment: .leading, spacing: 12) {
                                                RoundedRectangle(cornerRadius: 25)
                                                    .fill(outerColor)
                                                    .frame(width: 280, height: 180)
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(outerColor)
                                                    .frame(width: 200, height: 14)
                                            }
                                            .frame(width: 280)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(vm.articles) { article in
                                            NavigationLink(destination: DetailView(type: .news(article))) {
                                                ArticleCard(article: article)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        
                        // news horizontal list section removed
                        
                        // bottom spacing
                        Color.clear.frame(height: 20)
                    }
                }
            }
        }
        .onAppear {
            vm.fetchNames()
            vm.fetchRoutineSummary()
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
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                if let urlString = product.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 40))
                        .foregroundColor(secondaryColor.opacity(0.2))
                }
            }
            .frame(width: 160, height: 160)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(primaryText)
                    .lineLimit(1)
                
                Text(product.brand ?? "Unknown Brand")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 160)
    }
}

struct ArticleCard: View {
    let article: Articles
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                if let urlString = article.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 280, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                } else {
                    Image(systemName: "newspaper.fill")
                        .font(.system(size: 40))
                        .foregroundColor(secondaryColor.opacity(0.1))
                }
            }
            .frame(width: 280, height: 180)
            
            VStack(alignment: .leading, spacing: 4){
                Text(article.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(primaryText)
                    .lineLimit(1)
                
                Text(article.content ?? "")
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
