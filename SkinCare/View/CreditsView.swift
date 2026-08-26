//
//  CreditsView.swift
//  SkinCare
//

import SwiftUI

/// The sources behind the catalogue, and the licence each is used under.
///
/// This is not decoration. The product photographs are CC BY-SA 3.0 and the
/// listings are ODbL: both grant the right to use the work *on the condition*
/// that the source is credited. Ship the photos without this screen and the
/// licence is breached, however correct everything else is.
///
/// Names only, no prose. A licence screen is read to check a credit, not to
/// be told a story about where a photo came from.
struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss

    private struct Credit: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let links: [CreditLink]
    }

    private var credits: [Credit] {
        [
            Credit(
                icon: "camera",
                title: NSLocalizedString("credits_product_photos", comment: ""),
                links: [
                    CreditLink("Open Beauty Facts", "https://world.openbeautyfacts.org"),
                    CreditLink("CC BY-SA 3.0", "https://creativecommons.org/licenses/by-sa/3.0/"),
                ]
            ),
            Credit(
                icon: "list.bullet.rectangle",
                title: NSLocalizedString("credits_product_data", comment: ""),
                links: [
                    CreditLink("Open Beauty Facts", "https://world.openbeautyfacts.org/data"),
                    CreditLink("ODbL 1.0", "https://opendatacommons.org/licenses/odbl/1-0/"),
                ]
            ),
            Credit(
                icon: "photo",
                title: NSLocalizedString("credits_article_photos", comment: ""),
                links: [
                    CreditLink("Pexels", "https://www.pexels.com"),
                    CreditLink(NSLocalizedString("credits_pexels_license", comment: ""),
                               "https://www.pexels.com/license/"),
                ]
            ),
            Credit(
                icon: "shippingbox",
                title: NSLocalizedString("credits_open_source", comment: ""),
                links: [
                    CreditLink("Lottie", "https://github.com/airbnb/lottie-ios"),
                    CreditLink("RevenueCat", "https://github.com/RevenueCat/purchases-ios"),
                    CreditLink("MIT", "https://opensource.org/license/mit"),
                ]
            ),
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(credits) { credit in
                            CreditCard(
                                icon: credit.icon,
                                title: credit.title,
                                links: credit.links
                            )
                        }

                        Color.clear.frame(height: 12)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle(NSLocalizedString("credits", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppStrings.close) { dismiss() }
                }
            }
        }
    }
}

struct CreditLink: Identifiable {
    let id = UUID()
    let label: String
    let url: URL

    init(_ label: String, _ address: String) {
        self.label = label
        self.url = URL(string: address)!
    }
}

private struct CreditCard: View {
    let icon: String
    let title: String
    let links: [CreditLink]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.scaled(size: 16, weight: .semibold))
                    .foregroundColor(.brandPrimary)
                    .frame(width: 24)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.scaled(size: 16, weight: .bold))
                    .foregroundColor(.brandText)
            }

            // Wrapping, not a scroll view: licence names grow under larger
            // text sizes, and a licence link the user cannot see credits
            // nobody.
            WrappingRow(spacing: 8) {
                ForEach(links) { link in
                    Link(destination: link.url) {
                        HStack(spacing: 4) {
                            Text(link.label)
                            Image(systemName: "arrow.up.right")
                                .font(.scaled(size: 10, weight: .bold))
                        }
                        .font(.scaled(size: 13, weight: .semibold))
                        .foregroundColor(.brandPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.brandPrimary.opacity(0.08))
                        .cornerRadius(Radius.small)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
        .padding(.horizontal, 20)
    }
}

/// A row that moves to the next line instead of clipping.
///
/// SwiftUI has no wrapping stack, and the alternatives both fail here: an
/// `HStack` truncates the second licence name at accessibility text sizes,
/// and a horizontal `ScrollView` hides it behind a gesture nobody knows to
/// make.
struct WrappingRow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += rowWidth > 0 ? spacing + size.width : size.width
                rowHeight = max(rowHeight, size.height)
            }
        }
        return CGSize(width: maxWidth == .infinity ? rowWidth : maxWidth,
                      height: totalHeight + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
