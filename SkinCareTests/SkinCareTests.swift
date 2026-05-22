//
//  SkinCareTests.swift
//  SkinCareTests
//
//  Created by Kerem Öztopuz on 14.05.2026.
//

import XCTest
import Testing
@testable import SkinCare
internal import CoreData

@Test @MainActor func testContentViewFlow() {
    UserDefaults.standard.removeObject(forKey: "hasCompletedOnBoarding")
    UserDefaults.standard.removeObject(forKey: "hasCompletedProfile")
    UserDefaults.standard.removeObject(forKey: "hasCompletedSubscription")

    let vm = ContentViewModel()
    vm.showSplash = false
    XCTAssertEqual(vm.currentState, .onboarding)
    vm.completeOnBoarding()
    XCTAssertEqual(vm.currentState, .profileSetup)
    vm.completeProfile()
    XCTAssertEqual(vm.currentState, .loading)
    vm.showLoading = false
    XCTAssertEqual(vm.currentState, .subscription)
    vm.completePurchaseStep(isPremium: true)
    vm.showLoading = false
    vm.hasCompletedSubscription = true
    XCTAssertEqual(vm.currentState, .mainApp)
}

@Test func testProfileSetupValidation() {
    let vm = ProfileSetupViewModel()

    XCTAssertFalse(vm.isCurrentPageValid)
    vm.name = "Kerem"
    XCTAssertTrue(vm.isCurrentPageValid)
    vm.handleContinue()
    XCTAssertEqual(vm.currentPage, 1)
}

@Test func testRecentsViewModelMergeSort() {
    let context = PersistenceController.shared.container.viewContext

    let record1 = AnalysisRecord(context: context)
    record1.date = Date().addingTimeInterval(-86400 * 5)
    let record2 = AnalysisRecord(context: context)
    record2.date = Date()
    let record3 = AnalysisRecord(context: context)
    record3.date = Date().addingTimeInterval(-86400 * 10)

    let records = [record1, record2, record3]

    let vm = RecentsViewModel()
    let sorted = vm.mergeSort(records)

    XCTAssertEqual(sorted.first, record2)
    XCTAssertEqual(sorted.last, record3)

    context.rollback()
}

@Test @MainActor func testResultsViewModelRecommendations() async {
    let vm = ResultsViewModel(record: nil)
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    
    XCTAssertEqual(vm.recommendation.first, "Keep your skin hydrated and protected.")
}

@Test @MainActor func testProfileSetupFullPageNavigation() {
    let vm = ProfileSetupViewModel()

    XCTAssertEqual(vm.currentPage, 0)
    XCTAssertFalse(vm.isCurrentPageValid)
    vm.name = "Kerem"
    XCTAssertTrue(vm.isCurrentPageValid)
    vm.handleContinue()

    XCTAssertEqual(vm.currentPage, 1)
    XCTAssertTrue(vm.isCurrentPageValid)
    vm.handleContinue()

    XCTAssertEqual(vm.currentPage, 2)
    XCTAssertFalse(vm.isCurrentPageValid)
    vm.gender = .male
    XCTAssertTrue(vm.isCurrentPageValid)
    vm.handleContinue()

    XCTAssertEqual(vm.currentPage, 3)
    XCTAssertFalse(vm.isCurrentPageValid)
    vm.skinType = .oily
    XCTAssertTrue(vm.isCurrentPageValid)
}

@Test func testOnBoardingViewModelPages() {
    let vm = OnBoardingViewModel()

    XCTAssertEqual(vm.pages.count, 4)
    XCTAssertEqual(vm.currentPage, 0)

    for page in vm.pages {
        XCTAssertFalse(page.title.isEmpty)
        XCTAssertFalse(page.description.isEmpty)
        XCTAssertFalse(page.icon.isEmpty)
    }
}

@Test @MainActor func testContentViewFlowFreeUser() {
    UserDefaults.standard.removeObject(forKey: "hasCompletedOnBoarding")
    UserDefaults.standard.removeObject(forKey: "hasCompletedProfile")
    UserDefaults.standard.removeObject(forKey: "hasCompletedSubscription")

    let vm = ContentViewModel()
    vm.showSplash = false
    vm.completeOnBoarding()
    vm.completeProfile()
    vm.showLoading = false
    vm.completePurchaseStep(isPremium: false)
    vm.showLoading = false
    vm.hasCompletedSubscription = true

    XCTAssertEqual(vm.currentState, .mainApp)
    XCTAssertFalse(vm.isPremium)
}
