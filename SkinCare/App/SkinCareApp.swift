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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear() {
                    UserDefaults.standard.set(false, forKey:
                      "hasCompletedOnBoarding")
                    UserDefaults.standard.set(false, forKey:
                      "hasCompletedProfile")
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
