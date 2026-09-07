import Testing
import Foundation
import UIKit
import RevenueCat
internal import CoreData
@testable import SkinCare

@Test @MainActor func analysisWithoutConsentNeverStartsUpload() async {
    let defaults = UserDefaults.standard
    let previous = defaults.object(forKey: AIAnalysisConsent.key)
    defaults.removeObject(forKey: AIAnalysisConsent.key)
    defer { defaults.set(previous, forKey: AIAnalysisConsent.key) }
    do {
        _ = try await AnalysisService.shared.analyze(image: UIImage(), skinType: nil, age: nil)
        Issue.record("Analysis must require explicit consent")
    } catch AnalysisError.consentRequired {
        // Consent must fail before image encoding or a network request.
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}

@Test @MainActor func imageWithoutAFaceHasNoUploadCrop() async {
    let image = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100)).image { context in
        UIColor.red.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    let (crop, rect) = await withCheckedContinuation { continuation in
        CameraViewModel().detectFaceAndCrop(image) { crop, rect in
            continuation.resume(returning: (crop, rect))
        }
    }
    #expect(crop == nil)
    #expect(rect == .zero)
}

@Test @MainActor func trialRequiresEligibilityAndAFreeOffer() {
    var product = TestStoreProduct(
        localizedTitle: "Pro", price: 3.99, currencyCode: "USD",
        localizedPriceString: "$3.99", productIdentifier: "test.weekly",
        productType: .autoRenewableSubscription, localizedDescription: "Test",
        introductoryDiscount: TestStoreProductDiscount(
            identifier: "trial", price: 0, localizedPriceString: "$0",
            paymentMode: .freeTrial, subscriptionPeriod: .init(value: 3, unit: .day),
            numberOfPeriods: 1, type: .introductory
        ), locale: Locale(identifier: "en_US")
    )
    #expect(SubscriptionManager.trialPeriod(in: product.toStoreProduct(), eligibility: .ineligible) == nil)
    #expect(SubscriptionManager.trialPeriod(in: product.toStoreProduct(), eligibility: .unknown) == nil)
    if case .days(3) = SubscriptionManager.trialPeriod(in: product.toStoreProduct(), eligibility: .eligible) {
    } else { Issue.record("Eligible trial must preserve StoreKit duration") }
    product.introductoryDiscount = nil
    #expect(SubscriptionManager.trialPeriod(in: product.toStoreProduct(), eligibility: .eligible) == nil)
}

private final class FailingSaveContext: NSManagedObjectContext, @unchecked Sendable {
    var failSaves = false
    override func save() throws {
        if failSaves { throw NSError(domain: "TestSave", code: 1) }
        try super.save()
    }
}

@Test @MainActor func failedDeletionRollsBackAndReportsFailure() {
    let persistence = PersistenceController(inMemory: true)
    let context = FailingSaveContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = persistence.container.persistentStoreCoordinator
    let manager = LocalPersistenceManager(context: context)
    #expect(manager.saveUserProfile(name: "Keep me", skinType: "Normal", ageRange: "25", gender: "Other", knownIssues: ""))
    context.failSaves = true
    #expect(!manager.deleteAllUserData())
    #expect(manager.fetchUserProfile()?.name == "Keep me")
    context.failSaves = false
    #expect(manager.deleteAllUserData())
    #expect(manager.fetchUserProfile() == nil)
}

@Test @MainActor func unreadableStoreIsPreserved() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let url = directory.appendingPathComponent("history.sqlite")
    let original = Data("Unrecoverable test store: keep these bytes".utf8)
    try original.write(to: url)
    let persistence = PersistenceController(storeURL: url)
    #expect(persistence.loadFailed)
    #expect(!persistence.isReady)
    #expect(try Data(contentsOf: url) == original)
    persistence.loadStore()
    #expect(persistence.loadFailed)
    #expect(try Data(contentsOf: url) == original)
}

@Test @MainActor func routineReplacementAndBulkAcceptanceAreAtomic() throws {
    let persistence = PersistenceController(inMemory: true)
    let context = FailingSaveContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = persistence.container.persistentStoreCoordinator
    let manager = LocalPersistenceManager(context: context)
    func replace(_ name: String) -> Bool {
        manager.saveRoutineItem(productId: UUID(), productName: name, productBrand: nil,
                                productImageUrl: nil, productType: "cleanser", routineTime: "morning",
                                stepOrder: 0, isManuallyAdded: true)
    }
    #expect(replace("Original"))
    context.failSaves = true
    #expect(!replace("Lost replacement"))
    #expect(manager.fetchAllRoutineItems().map(\.productName) == ["Original"])
    #expect(!context.hasChanges)
    context.failSaves = false
    #expect(replace("Replacement"))
    #expect(manager.fetchAllRoutineItems().map(\.productName) == ["Replacement"])

    let suggestions = (0...1).map { step in
        let suggestion = RoutineSuggestion(context: context)
        suggestion.id = UUID()
        suggestion.productName = "Suggested \(step)"
        suggestion.routineTime = "morning"
        suggestion.stepOrder = Int16(step)
        suggestion.isAccepted = false
        return suggestion
    }
    try context.save()
    context.failSaves = true
    #expect(!manager.acceptSuggestions(suggestions))
    #expect(manager.fetchPendingSuggestions().count == 2)
    #expect(manager.fetchAllRoutineItems().map(\.productName) == ["Replacement"])
    context.failSaves = false
    #expect(manager.acceptSuggestions(suggestions))
    #expect(manager.fetchPendingSuggestions().isEmpty)
    #expect(manager.fetchAllRoutineItems().count == 2)
}

@Test @MainActor func scorePayloadRejectsInvalidRanges() throws {
    for value in ["-1", "101", "1e300", "null", "\"NaN\""] {
        let json = "{\"acne\":\(value),\"redness\":0,\"wrinkles\":10,\"eyebags\":20,\"pigmentation\":30,\"hydration\":100}"
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(AnalysisScores.self, from: Data(json.utf8))
        }
    }
    let valid = Data(#"{"acne":0,"redness":100,"wrinkles":10,"eyebags":20,"pigmentation":30,"hydration":100}"#.utf8)
    #expect(try JSONDecoder().decode(AnalysisScores.self, from: valid).redness == 100)
}

@Test @MainActor func comparisonUsesNewerMinusOlder() {
    #expect(CompareView.scoreChange(older: 40, newer: 70) == 30)
    #expect(CompareView.scoreChange(older: 70, newer: 40) == -30)
    #expect(CompareView.scoreChange(older: 40, newer: 40) == 0)
}
