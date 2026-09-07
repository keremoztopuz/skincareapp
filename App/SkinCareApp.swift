//
//  SkinCareApp.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 10.03.2026.
//

import SwiftUI
import RevenueCat
import TipKit
internal import CoreData

@main
struct SkinCareApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    @StateObject private var appVM = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if persistenceController.isReady {
                    ContentView()
                } else {
                    ContentUnavailableView {
                        Label("storage_unavailable_title", systemImage: "externaldrive.badge.exclamationmark")
                    } description: {
                        Text("storage_unavailable_message")
                    } actions: {
                        Button(AppStrings.tryAgain) { persistenceController.loadStore() }
                    }
                }
            }
                .preferredColorScheme(.light)
                // Scaled fonts support Dynamic Type; cap the range so
                // fixed-frame layouts stay intact at accessibility sizes.
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appVM)
                .onChange(of: persistenceController.isReady, initial: true) { _, ready in
                    guard ready else { return }
                    LocalPersistenceManager.shared.migrateScoresIfNeeded()
                    #if DEBUG
                    MockScanSeeder.seedIfRequested()
                    #endif
                }
        }
    }
    
    init() {
        do {
            try Tips.configure([.displayFrequency(.immediate)])
        } catch {
            AppLog.error("TipKit configuration failed", error)
        }
        // Set before configure, or the SDK's own start-up diagnostics — the
        // storefront, the product fetch and the reason an offering failed to
        // load — are gone by the time the level takes effect. Debug builds
        // only: the verbose log names product identifiers and prices.
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: RevenueCatConfig.apiKey)
    }
}
