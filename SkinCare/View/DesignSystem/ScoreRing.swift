//
//  ScoreRing.swift
//  SkinCare
//

import SwiftUI

/// Bands for the overall skin score (higher = better).
enum OverallBand {
    case excellent, good, fair, poor

    init(score: Double) {
        switch score {
        case 75...: self = .excellent
        case 50..<75: self = .good
        case 25..<50: self = .fair
        default: self = .poor
        }
    }

    var localizedTitle: String {
        switch self {
        case .excellent: return NSLocalizedString("overall_band_excellent", comment: "")
        case .good: return NSLocalizedString("overall_band_good", comment: "")
        case .fair: return NSLocalizedString("overall_band_fair", comment: "")
        case .poor: return NSLocalizedString("overall_band_poor", comment: "")
        }
    }
}

/// Severity label for individual condition bars (higher = worse).
enum Severity {
    case low, moderate, high

    init(score: Double) {
        switch score {
        case ..<25: self = .low
        case 25..<55: self = .moderate
        default: self = .high
        }
    }

    var localizedTitle: String {
        switch self {
        case .low: return NSLocalizedString("severity_low", comment: "")
        case .moderate: return NSLocalizedString("severity_moderate", comment: "")
        case .high: return NSLocalizedString("severity_high", comment: "")
        }
    }
}

/// Animated circular gauge for the overall skin score.
struct ScoreRing: View {
    let score: Double
    var size: CGFloat = 180
    var lineWidth: CGFloat = 14

    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.brandBlush, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress / 100)
                .stroke(
                    Color.brandPrimary,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(progress.rounded()))")
                        .font(.system(size: size * 0.26, weight: .bold))
                        .foregroundColor(.brandText)
                        .contentTransition(.numericText())
                    Text("/100")
                        .font(.system(size: size * 0.09, weight: .semibold))
                        .foregroundColor(.gray)
                }

                Text(OverallBand(score: score).localizedTitle)
                    .font(.system(size: size * 0.085, weight: .semibold))
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.brandBlush)
                    .cornerRadius(Radius.small)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                progress = min(max(score, 0), 100)
            }
        }
        // Without this a reused ring keeps showing the previous score.
        .onChange(of: score) { _, newScore in
            withAnimation(.easeOut(duration: 0.6)) {
                progress = min(max(newScore, 0), 100)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(Int(score)) /100, \(OverallBand(score: score).localizedTitle)"))
    }
}
