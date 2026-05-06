import SwiftUI

struct RecentsView: View {
    @StateObject private var vm = RecentsViewModel()
    
    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        
        ZStack {
            mainColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        if false {
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
                                    print("deneme")
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
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 600)
                            
                        } else {
                            Text("Recent Analysis")
                                .font(.system(size: 28, weight: .bold))
                                .padding(.horizontal, 20)
                                .padding(.top, 20)

                            // Time filter dropdown
                            Menu {
                                Button("All Time") { vm.selectedFilter = "All Time" }
                                Button("This Week") { vm.selectedFilter = "This Week" }
                                Button("This Month") { vm.selectedFilter = "This Month" }
                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16))
                                    Text(vm.selectedFilter)
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
                            .padding(.horizontal, 20)

                            ForEach(vm.records, id: \.self) { record in
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text(record.date ?? Date(), style: .date)
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Text(record.condition ?? "Unknown")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(secondaryColor)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 5)
                                            .background(Color(red: 1.0, green: 0.87, blue: 0.87))
                                            .cornerRadius(10)
                                    }
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("\(Int(record.overallScore))")
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                                        Text("/ 100")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    ScoreBar(label: "Dryness", value: record.drynessScore, color: secondaryColor)
                                    ScoreBar(label: "Inflammation", value: record.inflammationScore, color: secondaryColor)
                                    ScoreBar(label: "Oiliness", value: record.oilinessScore, color: secondaryColor)
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }
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
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(value))%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color.opacity(0.15))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: geo.size.width * (value / 100), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
    }
}

#Preview {
    RecentsView()
}
