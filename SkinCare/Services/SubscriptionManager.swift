import Foundation
import UIKit
import RevenueCat
internal import Combine

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    /// Must match the entitlement identifier in the RevenueCat dashboard.
    /// Both the monthly subscription and the lifetime purchase unlock it.
    static let proEntitlementID = "skanner_pro"

    /// Shown until StoreKit returns the storefront price (and if it never
    /// does). Keep in step with the App Store Connect price tiers — the live
    /// price always wins once the offerings load.
    enum FallbackPrice {
        static var monthly: String { forCurrency(turkish: "₺199,99", usd: "$3.99", eur: "€4,99") }
        static var lifetime: String { forCurrency(turkish: "₺899", usd: "$17.99", eur: "€19,99") }

        private static func forCurrency(turkish: String, usd: String, eur: String) -> String {
            switch Locale.current.currency?.identifier {
            case "TRY": return turkish
            case "EUR": return eur
            default: return usd
            }
        }
    }

    /// Length of a product's introductory free trial in days, or nil when
    /// App Store Connect carries no free-trial offer on it. Drives whether the
    /// paywalls may mention a trial at all.
    static func trialDays(in product: StoreProduct) -> Int? {
        guard let intro = product.introductoryDiscount, intro.paymentMode == .freeTrial else { return nil }
        let period = intro.subscriptionPeriod
        switch period.unit {
        case .day: return period.value
        case .week: return period.value * 7
        case .month: return period.value * 30
        case .year: return period.value * 365
        @unknown default: return period.value
        }
    }

    private init() {
        checkSubscriptionStatus()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func appWillEnterForeground() {
        checkSubscriptionStatus()
    }

    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { info, _ in
            guard let info = info else { return }
            DispatchQueue.main.async {
                let hasEntitlement = info.entitlements[Self.proEntitlementID]?.isActive == true
                let hasActiveSubscription = !info.activeSubscriptions.isEmpty
                self.isPremium = hasEntitlement || hasActiveSubscription
            }
        }
    }

    let freeMonthlyLimit = 5

    var isPremium: Bool {
        get { UserDefaults.standard.bool(forKey: "isPremium") }
        set {
            UserDefaults.standard.set(newValue, forKey: "isPremium")
            objectWillChange.send()
        }
    }

    // Stored as year * 100 + month so the quota resets across year boundaries.
    private var storedMonth: Int {
        get { UserDefaults.standard.integer(forKey: "scanMonth") }
        set { UserDefaults.standard.set(newValue, forKey: "scanMonth") }
    }

    private var storedCount: Int {
        get { UserDefaults.standard.integer(forKey: "monthlyScansCount") }
        set { UserDefaults.standard.set(newValue, forKey: "monthlyScansCount") }
    }

    private var currentMonthKey: Int {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        return (components.year ?? 0) * 100 + (components.month ?? 0)
    }

    var scansUsedThisMonth: Int {
        storedMonth == currentMonthKey ? storedCount : 0
    }

    var scansRemaining: Int {
        isPremium ? Int.max : max(0, freeMonthlyLimit - scansUsedThisMonth)
    }

    var canScan: Bool {
        isPremium || scansUsedThisMonth < freeMonthlyLimit
    }

    func recordScan() {
        let current = currentMonthKey
        if storedMonth != current {
            storedMonth = current
            storedCount = 1
        } else {
            storedCount += 1
        }
        objectWillChange.send()
    }
}
