//
//  SkinCareApp.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 10.03.2026.
//

import SwiftUI
import RevenueCat
internal import CoreData

@main
struct SkinCareApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var appVM = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                // Scaled fonts support Dynamic Type; cap the range so
                // fixed-frame layouts stay intact at accessibility sizes.
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appVM)
        }
    }
    
    init() {
        Purchases.configure(withAPIKey: RevenueCatConfig.apiKey)
        LocalPersistenceManager.shared.migrateScoresIfNeeded()
    }
}
