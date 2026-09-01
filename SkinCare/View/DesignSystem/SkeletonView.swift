//
//  SkeletonView.swift
//  SkinCare
//

import SwiftUI

/// A blush placeholder with a highlight band sweeping left to right.
///
/// Skeletons stand in for content that has not arrived yet, so they mimic the
/// shape of what is coming rather than spinning in place: the layout stays put
/// and nothing jumps when the real rows land. The sweep runs on the app-wide
/// 1.4s `easeInOut` rhythm, but does not autoreverse — the band flows one way
/// and restarts, the way a highlight travels across a surface.
private struct SkeletonShimmer: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    let bandWidth = geo.size.width * 0.6
                    LinearGradient(
                        colors: [
                            .white.opacity(0),
                            .white.opacity(0.65),
                            .white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: bandWidth)
                    .offset(x: isAnimating ? geo.size.width : -bandWidth)
                }
            }
            .clipped()
            .onAppear {
                // Reduce Motion keeps the placeholder — it just stops moving.
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

private extension View {
    func skeletonShimmer() -> some View {
        modifier(SkeletonShimmer())
    }
}

/// The building block every other skeleton is made of: a rounded blush
/// rectangle that shimmers.
struct SkeletonBox: View {
    var cornerRadius: CGFloat = Radius.card

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.brandBlush)
            .skeletonShimmer()
            .accessibilityHidden(true)
    }
}

/// Stacked bars standing in for a run of text. The last line is short so the
/// block reads as a paragraph rather than a solid slab.
struct SkeletonText: View {
    var lines: Int = 3
    var lineHeight: CGFloat = 12
    var spacing: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<max(lines, 1), id: \.self) { index in
                SkeletonBox(cornerRadius: Radius.small)
                    .frame(height: lineHeight)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(x: index == lines - 1 && lines > 1 ? 0.6 : 1,
                                 anchor: .leading)
            }
        }
        .accessibilityHidden(true)
    }
}

/// The shape of a list row: thumbnail on the left, a name and a brand line
/// beside it. Used by the Search list and the routine product picker.
struct SkeletonRow: View {
    var thumbnailSize: CGFloat = 60

    var body: some View {
        HStack(spacing: 16) {
            SkeletonBox(cornerRadius: Radius.small)
                .frame(width: thumbnailSize, height: thumbnailSize)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonBox(cornerRadius: Radius.small)
                    .frame(height: 14)
                SkeletonBox(cornerRadius: Radius.small)
                    .frame(height: 12)
                    .scaleEffect(x: 0.5, anchor: .leading)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .cardShadow()
        .accessibilityHidden(true)
    }
}

/// The shape of a horizontal carousel card: image block on top, name and
/// brand underneath. Matches `ProductCard` and `ArticleCard` on Home.
struct SkeletonCard: View {
    let width: CGFloat
    let height: CGFloat
    let imageHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonBox()
                .frame(height: imageHeight)

            VStack(alignment: .leading, spacing: 6) {
                SkeletonBox(cornerRadius: Radius.small)
                    .frame(height: 14)
                SkeletonBox(cornerRadius: Radius.small)
                    .frame(height: 12)
                    .scaleEffect(x: 0.6, anchor: .leading)
            }
        }
        .padding(12)
        .frame(width: width, height: height, alignment: .top)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .cardShadow()
        .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        Color.brandBackground.ignoresSafeArea()

        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    SkeletonCard(width: 172, height: 222, imageHeight: 132)
                    SkeletonCard(width: 172, height: 222, imageHeight: 132)
                }
                SkeletonRow()
                SkeletonRow()
                SkeletonText(lines: 5)
            }
            .padding(20)
        }
    }
}
