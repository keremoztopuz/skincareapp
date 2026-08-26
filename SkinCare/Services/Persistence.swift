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

    /// NSPersistentContainer(name:) loads a *fresh* NSManagedObjectModel each
    /// time, so a second controller (a preview, or a test running alongside
    /// `shared`) leaves two live models describing the same entities. Core
    /// Data then cannot map `AnalysisRecord` to a unique NSEntityDescription
    /// and saves fail with 134020. One model instance per process removes the
    /// ambiguity.
    private static let managedObjectModel: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "SkinCare", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("SkinCare.momd missing from the app bundle")
        }
        return model
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SkinCare", managedObjectModel: Self.managedObjectModel)
        if inMemory {
            // A true in-memory store, not SQLite-at-/dev/null: the /dev/null
            // form is shared between concurrently running tests, which makes
            // parallel saves fail with "store not compatible" (134020).
            let description = container.persistentStoreDescriptions.first!
            description.url = URL(fileURLWithPath: "/dev/null")
            description.type = NSInMemoryStoreType
        }
        let container = self.container
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // A store that cannot load (usually a failed migration or a
                // corrupt file) would otherwise brick the install with a
                // crash on every launch. Losing local history is bad;
                // permanently losing the whole app is worse — recreate the
                // store and carry on.
                AppLog.error("Persistent store failed to load, recreating", error)
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
