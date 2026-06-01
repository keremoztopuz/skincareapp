import SwiftUI
internal import CoreData

private func mockRecord(ctx: NSManagedObjectContext, overall: Double, acne: Double, redness: Double, daysAgo: Double) -> AnalysisRecord {
    let r = AnalysisRecord(context: ctx)
    r.date              = Date(timeIntervalSinceNow: -daysAgo * 86400)
    r.overallScore      = overall
    r.acneScore         = acne
    r.eczemaScore       = redness
    r.pigmentationScore = 30
    r.hydrationScore    = 65
    r.wrinkleScore      = 20
    r.eyebagScore       = 15
    r.drynessScore      = 40
    r.inflammationScore = 35
    r.oilinessScore     = 50
    r.condition         = "Acne"
    return r
}

struct CompareView: View {
    @Environment(\.dismiss) var dismiss
    let record1: AnalysisRecord
    let record2: AnalysisRecord

    let mainColor      = Color(red: 1.0, green: 0.97, blue: 0.97)
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let primaryText    = Color(red: 0.1,  green: 0.1,  blue: 0.2)

    private var analysisInsight: String {
        let overallDiff = record1.overallScore - record2.overallScore
        let acneDiff    = record1.acneScore    - record2.acneScore
        let wrinkleDiff = record1.wrinkleScore - record2.wrinkleScore
        var parts: [String] = []
        if overallDiff > 5 {
            parts.append(String(format: NSLocalizedString("compare_insight_overall_improved", comment: ""), Int(overallDiff)))
        } else if overallDiff < -5 {
            parts.append(String(format: NSLocalizedString("compare_insight_overall_decreased", comment: ""), Int(abs(overallDiff))))
        }
        if acneDiff < -5 {
            parts.append(NSLocalizedString("compare_insight_acne_decreased", comment: ""))
        } else if acneDiff > 5 {
            parts.append(NSLocalizedString("compare_insight_acne_increased", comment: ""))
        }
        if wrinkleDiff < -5 {
            parts.append(NSLocalizedString("compare_insight_wrinkles_decreased", comment: ""))
        }
        return parts.isEmpty
            ? NSLocalizedString("compare_insight_no_significant_change", comment: "")
            : parts.joined(separator: " ")
    }

    var body: some View {
        ZStack {
            mainColor.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {

                    // MARK: Back + Title
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
                        Text(NSLocalizedString("compare_analyses", comment: ""))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(primaryText)
                        Spacer()
                        Circle().fill(Color.clear).frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // MARK: Date labels
                    HStack {
                        dateLabel(record: record1, isLeft: true)
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .shadow(color: Color.black.opacity(0.07), radius: 5, x: 0, y: 2)
                            Text(NSLocalizedString("vs", comment: ""))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(secondaryColor)
                        }
                        Spacer()
                        dateLabel(record: record2, isLeft: false)
                    }
                    .padding(.horizontal, 24)

                    // MARK: Photos
                    HStack(spacing: 0) {
                        photoCard(record: record1)
                        Spacer()
                        photoCard(record: record2)
                    }
                    .padding(.horizontal, 24)

                    // MARK: Overall Score
                    metricRow(
                        label: AppStrings.overallScore,
                        val1: record1.overallScore,
                        val2: record2.overallScore,
                        unit: "",
                        higherIsBetter: true
                    )
                    .padding(.horizontal, 20)

                    // MARK: Divider
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 1)
                        .padding(.horizontal, 20)

                    // MARK: Skin Metrics title
                    HStack {
                        Text(NSLocalizedString("skin_metrics", comment: ""))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(primaryText)
                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // MARK: Detail rows with progress bars
                    VStack(spacing: 10) {
                        detailRow(label: AppStrings.acne,         val1: record1.acneScore,         val2: record2.acneScore,         higherIsBetter: false)
                        detailRow(label: AppStrings.redness,      val1: record1.eczemaScore,       val2: record2.eczemaScore,       higherIsBetter: false)
                        detailRow(label: AppStrings.pigmentation, val1: record1.pigmentationScore, val2: record2.pigmentationScore, higherIsBetter: false)
                        detailRow(label: AppStrings.hydration,    val1: record1.hydrationScore,    val2: record2.hydrationScore,    higherIsBetter: true)
                        detailRow(label: AppStrings.wrinkles,     val1: record1.wrinkleScore,      val2: record2.wrinkleScore,      higherIsBetter: false)
                        detailRow(label: AppStrings.eyeBags,      val1: record1.eyebagScore,       val2: record2.eyebagScore,       higherIsBetter: false)
                        detailRow(label: AppStrings.dryness,      val1: record1.drynessScore,      val2: record2.drynessScore,      higherIsBetter: false)
                        detailRow(label: AppStrings.inflammation, val1: record1.inflammationScore, val2: record2.inflammationScore, higherIsBetter: false)
                        detailRow(label: AppStrings.oiliness,     val1: record1.oilinessScore,     val2: record2.oilinessScore,     higherIsBetter: false)
                    }
                    .padding(.horizontal, 20)

                    // MARK: AI Insight
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 15))
                                .foregroundColor(secondaryColor)
                            Text(NSLocalizedString("ai_insight", comment: ""))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(secondaryColor)
                        }
                        Text(analysisInsight)
                            .font(.system(size: 14))
                            .foregroundColor(primaryText)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(Color(red: 1.0, green: 0.87, blue: 0.87))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Date Label
    @ViewBuilder
    private func dateLabel(record: AnalysisRecord, isLeft: Bool) -> some View {
        VStack(alignment: isLeft ? .leading : .trailing, spacing: 2) {
            Text(record.date ?? Date(), style: .date)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(secondaryColor)
            Text(record.date ?? Date(), style: .time)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }

    // MARK: - Photo Card
    @ViewBuilder
    private func photoCard(record: AnalysisRecord) -> some View {
        VStack(spacing: 6) {
            if let data = record.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 148, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.black.opacity(0.09), radius: 7, x: 0, y: 3)
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 1.0, green: 0.87, blue: 0.87))
                    .frame(width: 148, height: 180)
                    .overlay(
                        Image(systemName: "person.crop.rectangle")
                            .font(.system(size: 26))
                            .foregroundColor(secondaryColor.opacity(0.5))
                    )
            }
        }
    }

    // MARK: - Overall Metric Row (no bars)
    @ViewBuilder
    private func metricRow(label: String, val1: Double, val2: Double, unit: String, higherIsBetter: Bool) -> some View {
        let diff = val1 - val2
        let improved = higherIsBetter ? diff > 0 : diff < 0
        let diffColor: Color = diff == 0 ? .gray : (improved ? Color(red: 0.1, green: 0.6, blue: 0.3) : Color(red: 0.8, green: 0.1, blue: 0.1))
        let arrow = diff > 0 ? "↑" : (diff < 0 ? "↓" : "=")

        HStack {
            Text("\(Int(val1))\(unit)")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(primaryText)
                .frame(width: 72, alignment: .leading)
            Spacer()
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(primaryText)
                HStack(spacing: 3) {
                    Text(diff == 0 ? "= 0" : "\(diff > 0 ? "+" : "")\(Int(diff))\(unit)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(diffColor)
                    Text(arrow)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(diffColor)
                }
                Text(NSLocalizedString("vs", comment: ""))
                    .font(.system(size: 11))
                    .foregroundColor(.gray.opacity(0.5))
            }
            Spacer()
            Text("\(Int(val2))\(unit)")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.6))
                .frame(width: 72, alignment: .trailing)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Detail Row with dual progress bars
    @ViewBuilder
    private func detailRow(label: String, val1: Double, val2: Double, higherIsBetter: Bool) -> some View {
        let diff = val1 - val2
        let improved = higherIsBetter ? diff > 0 : diff < 0
        let diffColor: Color = diff == 0 ? .gray : (improved ? Color(red: 0.1, green: 0.6, blue: 0.3) : Color(red: 0.8, green: 0.1, blue: 0.1))
        let arrow = diff > 0 ? "↑" : (diff < 0 ? "↓" : "")

        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("\(Int(val1))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(primaryText)
                    .frame(width: 48, alignment: .leading)
                Spacer()
                VStack(spacing: 1) {
                    Text(label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(primaryText)
                    if diff != 0 {
                        Text("\(diff > 0 ? "+" : "")\(Int(diff))% \(arrow)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(diffColor)
                    }
                }
                Spacer()
                Text("\(Int(val2))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.6))
                    .frame(width: 48, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            HStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(secondaryColor.opacity(0.12)).frame(height: 5)
                        RoundedRectangle(cornerRadius: 3).fill(secondaryColor).frame(width: geo.size.width * min(val1 / 100, 1.0), height: 5)
                    }
                }
                .frame(height: 5)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.gray.opacity(0.15)).frame(height: 5)
                        RoundedRectangle(cornerRadius: 3).fill(Color(red: 0.55, green: 0.55, blue: 0.6)).frame(width: geo.size.width * min(val2 / 100, 1.0), height: 5)
                    }
                }
                .frame(height: 5)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 14)
        }
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
}

struct CompareViewPreviewWrapper: View {
    let ctx = PersistenceController.preview.container.viewContext
    var body: some View {
        let r1 = mockRecord(ctx: ctx, overall: 88, acne: 25, redness: 40, daysAgo: 0)
        let r2 = mockRecord(ctx: ctx, overall: 74, acne: 45, redness: 60, daysAgo: 7)
        CompareView(record1: r1, record2: r2)
    }
}

#Preview { CompareViewPreviewWrapper() }
