//
//  SkinCareApp.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 10.03.2026.
//

import SwiftUI
import CoreData

@main
struct SkinCareApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var appVM = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appVM)
        }
    }
}
