//
//  Persistence.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 10.03.2026.
//

internal import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SkinCare")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        let container = self.container
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // A store that cannot load (usually a failed migration or a
                // corrupt file) would otherwise brick the install with a
                // crash on every launch. Losing local history is bad;
                // permanently losing the whole app is worse — recreate the
                // store and carry on.
                NSLog("Persistent store failed to load, recreating: %@", error)
                if let url = storeDescription.url {
                    try? container.persistentStoreCoordinator.destroyPersistentStore(
                        at: url, ofType: NSSQLiteStoreType, options: nil
                    )
                    container.loadPersistentStores { _, retryError in
                        if let retryError {
                            // Disk-level failure (out of space, protection);
                            // nothing sensible left to do but crash with the
                            // real reason in the log.
                            fatalError("Persistent store unrecoverable: \(retryError)")
                        }
                    }
                }
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
