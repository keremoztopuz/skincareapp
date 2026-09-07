import Testing
import Foundation
import SwiftUI
import TipKit
internal import CoreData
@testable import SkinCare

@Test @MainActor func homeStatisticsTracksHistoryAndClearsDeletedRecords() throws {
    let context = PersistenceController(inMemory: true).container.viewContext
    let manager = LocalPersistenceManager(context: context)
    let vm = HomeViewModel(loadCloudData: false)
    vm.fetchStatistics(using: manager)
    #expect(!vm.hasStatistics)
    #expect(vm.scoreTrend.isEmpty)

    let start = Date(timeIntervalSince1970: 1_700_000_000)
    for index in 0..<12 {
        let record = AnalysisRecord(context: context)
        record.date = start.addingTimeInterval(Double(index) * 86400)
        record.overallScore = Double(index + 50)
        record.hydrationScore = 60
        record.oilinessScore = 30
        record.inflammationScore = 20
        try context.save()
        vm.fetchStatistics(using: manager)
        #expect(vm.hasStatistics)
        #expect(vm.scoreTrend.count == min(index + 1, 10))
    }
    #expect(vm.scoreTrend.map(\.score) == (52...61).map(Double.init))
    let identifiers = vm.scoreTrend.map(\.id)
    let undated = AnalysisRecord(context: context)
    undated.overallScore = 70
    try context.save()
    vm.fetchStatistics(using: manager)
    #expect(vm.scoreTrend.map(\.id) == identifiers)

    manager.deleteAllUserData()
    vm.fetchStatistics(using: manager)
    #expect(!vm.hasStatistics)
    #expect(vm.scoreTrend.isEmpty)
    #expect(vm.avgOverallScore == 0)
    #expect(vm.avgHydration == 0)
    #expect(vm.avgOiliness == 0)
    #expect(vm.avgInflammation == 0)
}

@available(iOS 26.0, *)
@Test @MainActor func renderTrendAndConditionLayouts() async throws {
    Tips.showAllTipsForTesting()
    let animationsWereEnabled = UIView.areAnimationsEnabled
    UIView.setAnimationsEnabled(false)
    defer { UIView.setAnimationsEnabled(animationsWereEnabled) }
    let context = PersistenceController(inMemory: true).container.viewContext
    let readings = [
        ConditionReading(key: "acne", title: AppStrings.acne, score: 68),
        ConditionReading(key: "redness", title: AppStrings.redness, score: 44),
        ConditionReading(key: "wrinkles", title: AppStrings.wrinkles, score: 20),
        ConditionReading(key: "eyebags", title: AppStrings.eyebags, score: 0),
        ConditionReading(key: "pigmentation", title: AppStrings.pigmentation, score: 100)
    ]
    let start = Date(timeIntervalSince1970: 1_700_000_000)
    let points = (0..<3).map { index in
        ScoreTrendPoint(id: AnalysisRecord(context: context).objectID,
                        date: start.addingTimeInterval(Double(index) * 86400),
                        score: Double(40 + index * 20))
    }
    for width in [375.0, 440.0] {
        for count in [0, 1, 3] {
            let visible = count == 0 ? readings.filter { !$0.isPro } : readings
            let content = VStack(spacing: 24) {
                ScoreTrendSection(points: Array(points.prefix(count)), onScan: {})
                TipView(ConditionInteractionTip(isPro: count != 0))
                VStack(spacing: 0) {
                    ForEach(visible) { reading in
                        ConditionRow(reading: reading, allTitles: visible.map(\.title), isSelected: reading.key == "acne")
                    }
                }
                .padding(12)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(20)
            .frame(width: width)
            .background(Color.brandBackground)
            .environment(\.dynamicTypeSize, width == 375 ? .accessibility1 : .large)
            .fixedSize(horizontal: false, vertical: true)
            .transaction { transaction in
                transaction.animation = nil
                transaction.disablesAnimations = true
            }
            let host = UIHostingController(rootView: content)
            host.safeAreaRegions = []
            let size = host.sizeThatFits(in: CGSize(width: width, height: 3000))
            let window = UIWindow(frame: CGRect(origin: .zero, size: size))
            window.rootViewController = host
            window.isHidden = false
            host.view.frame = window.bounds
            host.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(200))
            let finalSize = host.sizeThatFits(in: CGSize(width: width, height: 3000))
            window.frame.size = finalSize
            host.view.frame = window.bounds
            host.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(500))
            let image = UIGraphicsImageRenderer(size: finalSize).image { _ in
                host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
            }
            window.isHidden = true
            #expect(abs(Double(image.size.width) - width) < 0.5)
            let data = try #require(image.pngData())
            Attachment.record(Array(data), named: "layout-\(Int(width))-\(count).png")
        }
    }
}
