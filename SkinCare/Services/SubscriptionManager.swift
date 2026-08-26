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
        static var monthly: String { forCurrency(turkish: "₺99,99", usd: "$1.99", eur: "€1,99") }
        static var lifetime: String { forCurrency(turkish: "₺699,99", usd: "$12.99", eur: "€14,99") }

        private static func forCurrency(turkish: String, usd: String, eur: String) -> String {
            switch Locale.current.currency?.identifier {
            case "TRY": return turkish
            case "EUR": return eur
            default: return usd
            }
        }
    }

    /// A product's introductory free-trial length in its own store unit, or
    /// nil when App Store Connect carries no free-trial offer on it. Drives
    /// whether the paywalls may mention a trial at all. Kept in the store's
    /// unit so the paywall wording matches the App Store product page
    /// ("1 month free" must not become "30-Day").
    enum TrialPeriod {
        case days(Int), weeks(Int), months(Int), years(Int)

        var startCTA: String {
            switch self {
            case .days(let n): return String(format: NSLocalizedString("start_free_trial_%lld_days", comment: ""), n)
            case .weeks(let n): return String(format: NSLocalizedString("start_free_trial_%lld_weeks", comment: ""), n)
            case .months(let n): return String(format: NSLocalizedString("start_free_trial_%lld_months", comment: ""), n)
            case .years(let n): return String(format: NSLocalizedString("start_free_trial_%lld_years", comment: ""), n)
            }
        }
    }

    static func trialPeriod(in product: StoreProduct) -> TrialPeriod? {
        guard let intro = product.introductoryDiscount, intro.paymentMode == .freeTrial else { return nil }
        let period = intro.subscriptionPeriod
        switch period.unit {
        case .day: return .days(period.value)
        case .week: return .weeks(period.value)
        case .month: return .months(period.value)
        case .year: return .years(period.value)
        @unknown default: return .days(period.value)
        }
    }

    private init() {
        // Previews and the test target never call Purchases.configure;
        // touching Purchases.shared unconfigured is a fatal error.
        if Purchases.isConfigured {
            checkSubscriptionStatus()
            observeCustomerInfo()
        }
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

    private var customerInfoTask: Task<Void, Never>?

    /// Foreground polling alone leaves the UI stale for anything that lands
    /// while the app is open — a renewal, a billing failure, an expiry, or a
    /// refund. The stream pushes every one of those the moment RevenueCat
    /// sees it, so Pro is granted and revoked without waiting for a
    /// background/foreground round trip.
    private func observeCustomerInfo() {
        customerInfoTask = Task { [weak self] in
            for await info in Purchases.shared.customerInfoStream {
                let entitled = info.entitlements[Self.proEntitlementID]?.isActive == true
                await MainActor.run { self?.isPremium = entitled }
            }
        }
    }

    func checkSubscriptionStatus() {
        guard Purchases.isConfigured else { return }
        Purchases.shared.getCustomerInfo { info, _ in
            guard let info = info else { return }
            DispatchQueue.main.async {
                // The entitlement is the single source of truth. An
                // activeSubscriptions fallback used to live here as a
                // workaround for the misnamed "pro" entitlement; with the
                // identifier fixed it would only grant Pro to any future
                // non-Pro subscription SKU.
                self.isPremium = info.entitlements[Self.proEntitlementID]?.isActive == true
            }
        }
    }

    let freeMonthlyLimit = 5

    var isPremium: Bool {
        get { UserDefaults.standard.bool(forKey: "isPremium") }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue, forKey: "isPremium")
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
        objectWillChange.send()
        let current = currentMonthKey
        if storedMonth != current {
            storedMonth = current
            storedCount = 1
        } else {
            storedCount += 1
        }
    }
}
