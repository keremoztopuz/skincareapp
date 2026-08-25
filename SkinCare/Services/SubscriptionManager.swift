import Foundation
import UIKit
import RevenueCat
internal import Combine

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    /// Must match the entitlement identifier in the RevenueCat dashboard.
    /// Both the monthly subscription and the lifetime purchase unlock it.
    static let proEntitlementID = "skanner_pro"

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
