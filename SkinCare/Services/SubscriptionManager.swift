import Foundation
import RevenueCat
internal import Combine

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    private init() {
        checkSubscriptionStatus()
    }
    
    private func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { info, _ in
            guard let info = info else { return }
            DispatchQueue.main.async {
                let hasEntitlement = info.entitlements["pro"]?.isActive == true
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

    private var storedMonth: Int {
        get { UserDefaults.standard.integer(forKey: "scanMonth") }
        set { UserDefaults.standard.set(newValue, forKey: "scanMonth") }
    }

    private var storedCount: Int {
        get { UserDefaults.standard.integer(forKey: "monthlyScansCount") }
        set { UserDefaults.standard.set(newValue, forKey: "monthlyScansCount") }
    }

    var scansUsedThisMonth: Int {
        let current = Calendar.current.component(.month, from: Date())
        return storedMonth == current ? storedCount : 0
    }

    var scansRemaining: Int {
        isPremium ? Int.max : max(0, freeMonthlyLimit - scansUsedThisMonth)
    }

    var canScan: Bool {
        isPremium || scansUsedThisMonth < freeMonthlyLimit
    }

    func recordScan() {
        let current = Calendar.current.component(.month, from: Date())
        if storedMonth != current {
            storedMonth = current
            storedCount = 1
        } else {
            storedCount += 1
        }
        objectWillChange.send()
    }
}
