//
//  RecordCard.swift
//  SkinCare
//

import SwiftUI

/// Analysis record summary card: photo thumbnail, date, condition badge,
/// overall score and per-metric bars. Shared by the history list and its
/// locked (blurred) premium preview.
struct RecordCard: View {
    let record: AnalysisRecord
    var isCompareMode: Bool = false
    var isSelected: Bool = false
    /// Overall score change versus the previous scan; shows a trend chip when set.
    var delta: Double? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            if let data = record.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
            } else {
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(Color.brandBlush)
                    .frame(width: 120, height: 200)
                    .overlay(
                        Image(systemName: "person.crop.rectangle")
                            .font(.scaled(size: 24))
                            .foregroundColor(Color.brandPrimary.opacity(0.6))
                    )
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(record.date ?? Date(), style: .date)
                        .font(.scaled(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    if isCompareMode {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.scaled(size: 22))
                            .foregroundColor(isSelected ? Color.brandPrimary : Color.gray.opacity(0.4))
                            .animation(.spring(response: 0.2), value: isSelected)
                    } else {
                        Text(AppStrings.localizedCondition(record.condition))
                            .font(.scaled(size: 13, weight: .semibold))
                            .foregroundColor(.brandPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.brandBlush)
                            .cornerRadius(Radius.small)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(record.overallScore))")
                        .font(.scaled(size: 36, weight: .bold))
                        .foregroundColor(.brandText)
                    Text("/100")
                        .font(.scaled(size: 16))
                        .foregroundColor(.gray)

                    if let delta, abs(delta) >= 1 {
                        HStack(spacing: 2) {
                            Image(systemName: delta > 0 ? "arrow.up" : "arrow.down")
                                .font(.scaled(size: 10, weight: .bold))
                            Text("\(abs(Int(delta)))")
                                .font(.scaled(size: 12, weight: .bold))
                        }
                        .foregroundColor(delta > 0 ? .brandPositive : .brandNegative)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background((delta > 0 ? Color.brandPositive : Color.brandNegative).opacity(0.1))
                        .cornerRadius(Radius.small)
                    }
                }

                ScoreBar(label: AppStrings.hydration, value: record.hydrationScore)
                ScoreBar(label: AppStrings.inflammation, value: record.inflammationScore)
                ScoreBar(label: AppStrings.oiliness, value: record.oilinessScore)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: Radius.card)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.card)
                        .stroke(isSelected ? Color.brandPrimary : Color.clear, lineWidth: 2)
                )
        )
        .cardShadow()
        .padding(.horizontal, 20)
    }
}
