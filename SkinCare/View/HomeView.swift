import SwiftUI
import Charts
import AVFoundation
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
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        // greeting Section
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(greetingText), \(vm.userName)")
                                .font(.system(size: 31, weight: .bold))
                                .foregroundColor(.brandText)
                                .lineLimit(2)
                                .minimumScaleFactor(0.82)
                            
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
                                Button(AppStrings.tryAgain) {
                                    Task { await vm.fetchAllCloudData() }
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.brandPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                        
                        // analysis Button
                        Button(action: {
                            selectedTab = 2
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: Radius.card)
                                    .fill(Color.brandBlush)
                                    .frame(height: 210)

                                Circle()
                                    .fill(Color.brandPrimary)
                                    .frame(width: 142, height: 142)
                                    .overlay {
                                        VStack(spacing: 10) {
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 44, weight: .medium))
                                                .foregroundColor(.white)

                                            Text(NSLocalizedString("skin_analysis", comment: ""))
                                                .foregroundColor(.white)
                                                .font(.system(size: 15, weight: .bold))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                        }
                                    }
                            }
                            .cardShadow()
                        }
                        .padding(.horizontal, 20)
                        
                        // skin health grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("your_skin_health_avg", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.brandText)

                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ],
                                spacing: 12
                            ) {
                                MetricCard(value: "\(vm.avgOverallScore)", label: AppStrings.overallScore, icon: "heart.text.square.fill", progress: Double(vm.avgOverallScore))
                                MetricCard(value: "\(vm.avgDryness)%", label: AppStrings.dryness, icon: "drop.triangle.fill", progress: Double(vm.avgDryness))
                                MetricCard(value: "\(vm.avgOiliness)%", label: AppStrings.oiliness, icon: "drop.halffull", progress: Double(vm.avgOiliness))
                                MetricCard(value: "\(vm.avgInflammation)%", label: AppStrings.inflammation, icon: "flame.fill", progress: Double(vm.avgInflammation))
                            }
                        }
                        .padding(.horizontal, 20)

                        // score trend
                        if vm.scoreTrend.count >= 2 {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(NSLocalizedString("score_trend", comment: ""))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.brandText)

                                Chart(vm.scoreTrend) { point in
                                    LineMark(
                                        x: .value("Date", point.date),
                                        y: .value("Score", point.score)
                                    )
                                    .foregroundStyle(Color.brandPrimary)
                                    .interpolationMethod(.catmullRom)
                                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

                                    PointMark(
                                        x: .value("Date", point.date),
                                        y: .value("Score", point.score)
                                    )
                                    .foregroundStyle(Color.brandPrimary)
                                    .symbolSize(36)
                                }
                                .chartYScale(domain: 0...100)
                                .chartXAxis {
                                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                                        AxisValueLabel(format: .dateTime.day().month(), centered: false)
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading, values: [0, 50, 100]) { value in
                                        AxisGridLine()
                                            .foregroundStyle(Color.brandBlush)
                                        AxisValueLabel()
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                .frame(height: 160)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(Radius.card)
                                .cardShadow()
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // routine card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(NSLocalizedString("your_routine", comment: ""))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.brandText)
                                if vm.hasPendingSuggestions {
                                    Circle()
                                        .fill(Color.brandPrimary)
                                        .frame(width: 8, height: 8)
                                }
                            }

                            NavigationLink(destination: RoutineView(selectedTab: $selectedTab)) {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack(alignment: .top) {
                                        Text(routineTitle)
                                            .font(.system(size: 22, weight: .bold))
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.85)
                                        Spacer(minLength: 16)
                                        Image(systemName: routineIcon)
                                            .font(.system(size: 22, weight: .semibold))
                                            .frame(width: 34, height: 34)
                                            .background(Color.white.opacity(0.16))
                                            .clipShape(Circle())
                                    }

                                    if vm.routineItemCount > 0 {
                                        Text(String(format: NSLocalizedString("steps_configured_%lld", comment: ""), vm.routineItemCount))
                                            .font(.system(size: 15, weight: .medium))
                                            .opacity(0.9)

                                        HStack(spacing: 8) {
                                            ForEach(Array(vm.routineStepNames.prefix(3)), id: \.self) { name in
                                                Text(name)
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.8)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 7)
                                                    .background(Color.white.opacity(0.16))
                                                    .clipShape(Capsule())
                                            }

                                            if vm.routineStepNames.count > 3 {
                                                Text("+\(vm.routineStepNames.count - 3)")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 7)
                                                    .background(Color.white.opacity(0.16))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        Text(NSLocalizedString("tap_to_setup_routine", comment: ""))
                                            .font(.system(size: 15, weight: .medium))
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .opacity(0.9)
                                    }
                                }
                                .foregroundColor(.white)
                                .padding(22)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(minHeight: 150)
                                .background(Color.brandPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                                .cardShadow()
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        
                        // products horizontal list
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("recommended_products", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.brandText)
                                .padding(.horizontal, 20)

                            if vm.isLoading && vm.products.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(0..<3, id: \.self) { _ in
                                            RoundedRectangle(cornerRadius: Radius.card)
                                                .fill(Color.brandBlush)
                                                .frame(width: 172, height: 222)
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
                                .foregroundColor(.brandText)
                                .padding(.horizontal, 20)

                            if vm.isLoading && vm.articles.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(0..<2, id: \.self) { _ in
                                            RoundedRectangle(cornerRadius: Radius.card)
                                                .fill(Color.brandBlush)
                                                .frame(width: 282, height: 246)
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
                        
                        // bottom spacing
                        Color.clear.frame(height: 20)
                    }
                }
            }
        }
        .onAppear {
            vm.fetchNames()
            vm.fetchStatistics()
            vm.fetchRoutineSummary()
        }
    }
}

// MARK: - Subviews
struct MetricCard: View {
    let value: String
    let label: String
    let icon: String
    var progress: Double? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.brandPrimary)
                    .frame(width: 30, height: 30)
                    .background(Color.brandPrimary.opacity(0.10))
                    .clipShape(Circle())

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.brandPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }

            if let progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: Radius.small)
                            .fill(Color.brandBlush)
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: Radius.small)
                            .fill(Color.brandPrimary)
                            .frame(width: geo.size.width * (min(max(progress, 0), 100) / 100), height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 130)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .cardShadow()
    }
}

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(Color.brandPrimary.opacity(0.06))

                if let urlString = product.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 148, height: 132)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                } else {
                    Image(systemName: "bottle.condiment.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.brandPrimary.opacity(0.2))
                }
            }
            .frame(width: 148, height: 132)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.brandText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(product.brand ?? AppStrings.unknownBrand)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(width: 172, height: 222, alignment: .top)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .cardShadow()
    }
}

struct ArticleCard: View {
    let article: Articles

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(Color.brandPrimary.opacity(0.06))

                if let urlString = article.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 258, height: 148)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                } else {
                    Image(systemName: "newspaper.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.brandPrimary.opacity(0.1))
                }
            }
            .frame(width: 258, height: 148)

            VStack(alignment: .leading, spacing: 4){
                Text(article.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.brandText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(article.content ?? "")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(width: 282, height: 246, alignment: .top)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .cardShadow()
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
