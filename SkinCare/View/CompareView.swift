import SwiftUI
internal import CoreData

struct CompareView: View {
    @Environment(\.dismiss) var dismiss
    let record1: AnalysisRecord
    let record2: AnalysisRecord

    // Callers pass records in tap order, which is arbitrary; every diff and
    // layout decision derives from these so the insight can never invert.
    private var older: AnalysisRecord {
        (record1.date ?? .distantPast) <= (record2.date ?? .distantPast) ? record1 : record2
    }
    private var newer: AnalysisRecord {
        (record1.date ?? .distantPast) <= (record2.date ?? .distantPast) ? record2 : record1
    }

    /// The rebuilt scoring formula spans a wider 0-100 range, so an 8-point
    /// deadband keeps the insight copy as selective as the old 5 was.
    private static let deadband: Double = 8

    private var analysisInsight: String {
        let overallDiff = newer.overallScore - older.overallScore
        let acneDiff    = newer.acneScore    - older.acneScore
        let wrinkleDiff = newer.wrinkleScore - older.wrinkleScore
        var parts: [String] = []
        if overallDiff > Self.deadband {
            parts.append(String(format: NSLocalizedString("compare_insight_overall_improved", comment: ""), Int(overallDiff)))
        } else if overallDiff < -Self.deadband {
            parts.append(String(format: NSLocalizedString("compare_insight_overall_decreased", comment: ""), Int(abs(overallDiff))))
        }
        if acneDiff < -Self.deadband {
            parts.append(NSLocalizedString("compare_insight_acne_decreased", comment: ""))
        } else if acneDiff > Self.deadband {
            parts.append(NSLocalizedString("compare_insight_acne_increased", comment: ""))
        }
        if wrinkleDiff < -Self.deadband {
            parts.append(NSLocalizedString("compare_insight_wrinkles_decreased", comment: ""))
        } else if wrinkleDiff > Self.deadband {
            parts.append(NSLocalizedString("compare_insight_wrinkles_increased", comment: ""))
        }
        return parts.isEmpty
            ? NSLocalizedString("compare_insight_no_significant_change", comment: "")
            : parts.joined(separator: " ")
    }

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {

                    // MARK: Back + Title
                    BackHeaderBar(title: NSLocalizedString("compare_analyses", comment: "")) { dismiss() }

                    // MARK: Date labels
                    HStack {
                        dateLabel(record: older, isLeft: true)
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .cardShadow()
                            Text(NSLocalizedString("vs", comment: ""))
                                .font(.scaled(size: 12, weight: .bold))
                                .foregroundColor(.brandPrimary)
                        }
                        Spacer()
                        dateLabel(record: newer, isLeft: false)
                    }
                    .padding(.horizontal, 24)

                    // MARK: Photos
                    HStack(spacing: 0) {
                        photoCard(record: older)
                        Spacer()
                        photoCard(record: newer)
                    }
                    .padding(.horizontal, 24)

                    // MARK: Overall Score
                    metricRow(
                        label: AppStrings.overallScore,
                        val1: older.overallScore,
                        val2: newer.overallScore,
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
                            .font(.scaled(size: 17, weight: .bold))
                            .foregroundColor(.brandText)
                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // MARK: Detail rows with progress bars
                    VStack(spacing: 10) {
                        detailRow(label: AppStrings.acne,         val1: older.acneScore,         val2: newer.acneScore,         higherIsBetter: false)
                        detailRow(label: AppStrings.redness,      val1: older.eczemaScore,       val2: newer.eczemaScore,       higherIsBetter: false)
                        detailRow(label: AppStrings.pigmentation, val1: older.pigmentationScore, val2: newer.pigmentationScore, higherIsBetter: false)
                        detailRow(label: AppStrings.wrinkles,     val1: older.wrinkleScore,      val2: newer.wrinkleScore,      higherIsBetter: false)
                        detailRow(label: AppStrings.eyeBags,      val1: older.eyebagScore,       val2: newer.eyebagScore,       higherIsBetter: false)
                        detailRow(label: AppStrings.hydration,    val1: older.hydrationScore,    val2: newer.hydrationScore,    higherIsBetter: true)
                        detailRow(label: AppStrings.inflammation, val1: older.inflammationScore, val2: newer.inflammationScore, higherIsBetter: false)
                        detailRow(label: AppStrings.oiliness,     val1: older.oilinessScore,     val2: newer.oilinessScore,     higherIsBetter: false)
                    }
                    .padding(.horizontal, 20)

                    // MARK: Insight
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.scaled(size: 15))
                                .foregroundColor(.brandPrimary)
                            Text(NSLocalizedString("ai_insight", comment: ""))
                                .font(.scaled(size: 15, weight: .bold))
                                .foregroundColor(.brandPrimary)
                        }
                        Text(analysisInsight)
                            .font(.scaled(size: 14))
                            .foregroundColor(.brandText)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(Color.brandBlush)
                    .cornerRadius(Radius.card)
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
                .font(.scaled(size: 13, weight: .semibold))
                .foregroundColor(.brandPrimary)
            Text(record.date ?? Date(), style: .time)
                .font(.scaled(size: 12))
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
                    .frame(maxWidth: 148)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                    .cardShadow()
            } else {
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(Color.brandBlush)
                    .frame(maxWidth: 148)
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "person.crop.rectangle")
                            .font(.scaled(size: 26))
                            .foregroundColor(Color.brandPrimary.opacity(0.5))
                    )
            }
        }
    }

    // MARK: - Overall Metric Row (no bars)
    @ViewBuilder
    private func metricRow(label: String, val1: Double, val2: Double, unit: String, higherIsBetter: Bool) -> some View {
        let diff = val1 - val2
        let improved = higherIsBetter ? diff > 0 : diff < 0
        let diffColor: Color = diff == 0 ? .gray : (improved ? .brandPositive : .brandNegative)

        HStack {
            Text("\(Int(val1))\(unit)")
                .font(.scaled(size: 26, weight: .bold))
                .foregroundColor(.brandText)
                .frame(width: 72, alignment: .leading)
            Spacer()
            VStack(spacing: 2) {
                Text(label)
                    .font(.scaled(size: 13, weight: .semibold))
                    .foregroundColor(.brandText)
                HStack(spacing: 3) {
                    Text(diff == 0 ? "0" : "\(diff > 0 ? "+" : "")\(Int(diff))\(unit)")
                        .font(.scaled(size: 12, weight: .bold))
                        .foregroundColor(diffColor)
                    if diff != 0 {
                        Image(systemName: diff > 0 ? "arrow.up" : "arrow.down")
                            .font(.scaled(size: 10, weight: .bold))
                            .foregroundColor(diffColor)
                    }
                }
                Text(NSLocalizedString("vs", comment: ""))
                    .font(.scaled(size: 11))
                    .foregroundColor(.gray.opacity(0.5))
            }
            Spacer()
            Text("\(Int(val2))\(unit)")
                .font(.scaled(size: 26, weight: .bold))
                .foregroundColor(.gray)
                .frame(width: 72, alignment: .trailing)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
    }

    // MARK: - Detail Row with dual progress bars
    @ViewBuilder
    private func detailRow(label: String, val1: Double, val2: Double, higherIsBetter: Bool) -> some View {
        let diff = val1 - val2
        let improved = higherIsBetter ? diff > 0 : diff < 0
        let diffColor: Color = diff == 0 ? .gray : (improved ? .brandPositive : .brandNegative)

        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("\(Int(val1))%")
                    .font(.scaled(size: 16, weight: .bold))
                    .foregroundColor(.brandText)
                    .frame(width: 48, alignment: .leading)
                Spacer()
                VStack(spacing: 1) {
                    Text(label)
                        .font(.scaled(size: 13, weight: .semibold))
                        .foregroundColor(.brandText)
                    if diff != 0 {
                        HStack(spacing: 3) {
                            Text("\(diff > 0 ? "+" : "")\(Int(diff))%")
                                .font(.scaled(size: 11, weight: .bold))
                                .foregroundColor(diffColor)
                            Image(systemName: diff > 0 ? "arrow.up" : "arrow.down")
                                .font(.scaled(size: 9, weight: .bold))
                                .foregroundColor(diffColor)
                        }
                    }
                }
                Spacer()
                Text("\(Int(val2))%")
                    .font(.scaled(size: 16, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: 48, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            HStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: Radius.small).fill(Color.brandPrimary.opacity(0.12)).frame(height: 5)
                        RoundedRectangle(cornerRadius: Radius.small).fill(Color.brandPrimary).frame(width: geo.size.width * min(max(val1, 0) / 100, 1.0), height: 5)
                    }
                }
                .frame(height: 5)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: Radius.small).fill(Color.gray.opacity(0.15)).frame(height: 5)
                        RoundedRectangle(cornerRadius: Radius.small).fill(Color.gray).frame(width: geo.size.width * min(max(val2, 0) / 100, 1.0), height: 5)
                    }
                }
                .frame(height: 5)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 14)
        }
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
    }
}

#if DEBUG
private func mockRecord(ctx: NSManagedObjectContext, overall: Double, acne: Double, redness: Double, daysAgo: Double) -> AnalysisRecord {
    let r = AnalysisRecord(context: ctx)
    r.date              = Date(timeIntervalSinceNow: -daysAgo * 86400)
    r.overallScore      = overall
    r.acneScore         = acne
    r.eczemaScore       = redness
    r.pigmentationScore = 30
    r.wrinkleScore      = 20
    r.eyebagScore       = 15
    r.hydrationScore    = 62
    r.inflammationScore = 35
    r.oilinessScore     = 50
    r.condition         = "Acne"
    return r
}

private struct CompareViewPreviewWrapper: View {
    let ctx = PersistenceController.preview.container.viewContext
    var body: some View {
        let r1 = mockRecord(ctx: ctx, overall: 88, acne: 25, redness: 40, daysAgo: 0)
        let r2 = mockRecord(ctx: ctx, overall: 74, acne: 45, redness: 60, daysAgo: 7)
        CompareView(record1: r1, record2: r2)
    }
}

#Preview { CompareViewPreviewWrapper() }
#endif
