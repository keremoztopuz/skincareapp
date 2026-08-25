//
//  SkinCareTests.swift
//  SkinCareTests
//
//  Created by Kerem Öztopuz on 14.05.2026.
//

import Testing
import Foundation
@testable import SkinCare
internal import CoreData

private func resetAppFlowDefaults() {
    // Write explicit false instead of removing: the host app (or a cloned
    // simulator) may have seeded these true, and an explicit write is
    // authoritative even when a stale cfprefsd cache survives removal.
    UserDefaults.standard.set(false, forKey: "hasCompletedOnBoarding")
    UserDefaults.standard.set(false, forKey: "hasAcceptedDisclaimer")
    UserDefaults.standard.set(false, forKey: "hasCompletedProfile")
    UserDefaults.standard.set(false, forKey: "hasCompletedSubscription")
    UserDefaults.standard.set(false, forKey: "isPremium")
}

@Test @MainActor func testContentViewFlow() {
    resetAppFlowDefaults()

    let vm = ContentViewModel()
    vm.showSplash = false
    #expect(vm.currentState == .onboarding)
    vm.completeOnBoarding()
    #expect(vm.currentState == .disclaimer)
    vm.acceptDisclaimer()
    #expect(vm.currentState == .profileSetup)
    vm.completeProfile()
    #expect(vm.currentState == .loading)
    vm.showLoading = false
    #expect(vm.currentState == .subscription)
    vm.completePurchaseStep(isPremium: true)
    vm.showLoading = false
    vm.hasCompletedSubscription = true
    #expect(vm.currentState == .mainApp)
}

@Test func testProfileSetupValidation() {
    let vm = ProfileSetupViewModel()

    #expect(!vm.isCurrentPageValid)
    vm.name = "Kerem"
    #expect(vm.isCurrentPageValid)
    vm.handleContinue()
    #expect(vm.currentPage == 1)
}

@Test func testAnalysisRecordsFetchNewestFirst() throws {
    let context = PersistenceController(inMemory: true).container.viewContext
    let manager = LocalPersistenceManager(context: context)

    let record1 = AnalysisRecord(context: context)
    record1.date = Date().addingTimeInterval(-86400 * 5)
    let record2 = AnalysisRecord(context: context)
    record2.date = Date()
    let record3 = AnalysisRecord(context: context)
    record3.date = Date().addingTimeInterval(-86400 * 10)

    try context.save()

    // Relative order only: "/dev/null" SQLite stores are shared between
    // concurrently running tests, so the fetch may contain records saved
    // by other tests too.
    let sorted = manager.fetchAnalysisRecords()
    let newest = try #require(sorted.firstIndex(of: record2))
    let middle = try #require(sorted.firstIndex(of: record1))
    let oldest = try #require(sorted.firstIndex(of: record3))

    #expect(newest < middle)
    #expect(middle < oldest)
}

@Test @MainActor func testResultsViewModelRecommendations() async {
    let vm = ResultsViewModel(record: nil)
    await vm.generateRecommendations()

    #expect(vm.recommendation.first == String(localized: "recommendation_keep_hydrated"))
}

@Test @MainActor func testProfileSetupFullPageNavigation() {
    let vm = ProfileSetupViewModel()

    #expect(vm.currentPage == 0)
    #expect(!vm.isCurrentPageValid)
    vm.name = "Kerem"
    #expect(vm.isCurrentPageValid)
    vm.handleContinue()

    #expect(vm.currentPage == 1)
    #expect(vm.isCurrentPageValid)
    vm.handleContinue()

    #expect(vm.currentPage == 2)
    #expect(!vm.isCurrentPageValid)
    vm.gender = .male
    #expect(vm.isCurrentPageValid)
    vm.handleContinue()

    #expect(vm.currentPage == 3)
    #expect(!vm.isCurrentPageValid)
    vm.skinType = .oily
    #expect(vm.isCurrentPageValid)
}

@Test func testOnBoardingViewModelPages() {
    let vm = OnBoardingViewModel()

    #expect(vm.pages.count == 4)
    #expect(vm.currentPage == 0)

    for page in vm.pages {
        #expect(!page.title.isEmpty)
        #expect(!page.description.isEmpty)
        #expect(!page.icon.isEmpty)
    }
}

@Test @MainActor func testContentViewFlowFreeUser() {
    resetAppFlowDefaults()

    let vm = ContentViewModel()
    vm.showSplash = false
    vm.completeOnBoarding()
    vm.acceptDisclaimer()
    vm.completeProfile()
    vm.showLoading = false
    vm.completePurchaseStep(isPremium: false)
    vm.showLoading = false
    vm.hasCompletedSubscription = true

    #expect(vm.currentState == .mainApp)
    #expect(!SubscriptionManager.shared.isPremium)
}
