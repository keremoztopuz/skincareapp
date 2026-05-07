import SwiftUI

struct RecentsView: View {
    @StateObject private var vm = RecentsViewModel()
    
    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        
        NavigationStack {
            ZStack {
                mainColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            if vm.records.isEmpty {
                                EmptyStateView()
                            } else {
                                Text("Recent Analysis")
                                    .font(.system(size: 28, weight: .bold))
                                    .padding(.horizontal, 20)
                                    .padding(.top, 20)
                                
                                // Time filter dropdown
                                FilterMenu(selectedFilter: $vm.selectedFilter)
                                    .padding(.horizontal, 20)
                                
                                ForEach(vm.records, id: \.self) { record in
                                    NavigationLink(destination: Text("Result View for \(record.condition ?? "")")) {
                                        AnalysisCard(record: record)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

struct AnalysisCard: View {
    let record: AnalysisRecord
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    
    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Image Section (Small and centered on the left)
            ZStack {
                if let imageData = record.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("guidegood1") // Placeholder
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 70, height: 70)
            .cornerRadius(12)
            .clipped()
            .padding(.leading, 12)
            
            // MARK: - Info Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(record.date ?? Date(), style: .date)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(record.condition ?? "Acne")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(secondaryColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(secondaryColor.opacity(0.1))
                        .cornerRadius(8)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(record.overallScore))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    Text("/ 100")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 8) {
                    ScoreBar(label: "Dryness", value: record.drynessScore, color: secondaryColor)
                    ScoreBar(label: "Inflammation", value: record.inflammationScore, color: secondaryColor)
                    ScoreBar(label: "Oiliness", value: record.oilinessScore, color: secondaryColor)
                }
            }
            .padding(.vertical, 16)
            .padding(.trailing, 16)
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

struct ScoreBar: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray.opacity(0.8))
                Spacer()
                Text("\(Int(value))%")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.1))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * (value / 100), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

struct FilterMenu: View {
    @Binding var selectedFilter: String
    
    var body: some View {
        Menu {
            Button("All Time") { selectedFilter = "All Time" }
            Button("This Week") { selectedFilter = "This Week" }
            Button("This Month") { selectedFilter = "This Month" }
        } label: {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                Text(selectedFilter)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
            }
            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
    }
}

struct EmptyStateView: View {
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.87, blue:0.87))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(secondaryColor)
                    .frame(width: 110, height: 110)
                Image(systemName: "camera")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 10) {
                Text("No Analysis Yet")
                    .font(.system(size: 24, weight: .bold))
                Text("Go to camera view to make your first scan")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                print("Redirect to camera")
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 20))
                    Text("Make your first scan")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 16)
                .background(secondaryColor)
                .cornerRadius(16)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 600)
    }
}

#Preview {
    RecentsView()
}
