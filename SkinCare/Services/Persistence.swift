//
//  Persistence.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 10.03.2026.
//

internal import CoreData
internal import Combine

final class PersistenceController: ObservableObject {
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
    @Published private(set) var isReady = false
    @Published private(set) var loadFailed = false

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

    init(inMemory: Bool = false, storeURL: URL? = nil) {
        container = NSPersistentContainer(name: "SkinCare", managedObjectModel: Self.managedObjectModel)
        if let storeURL { container.persistentStoreDescriptions.first?.url = storeURL }
        if inMemory {
            // A true in-memory store, not SQLite-at-/dev/null: the /dev/null
            // form is shared between concurrently running tests, which makes
            // parallel saves fail with "store not compatible" (134020).
            let description = container.persistentStoreDescriptions.first!
            description.url = URL(fileURLWithPath: "/dev/null")
            description.type = NSInMemoryStoreType
        }
        container.persistentStoreDescriptions.first?.shouldAddStoreAsynchronously = false
        loadStore()
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func loadStore() {
        guard !isReady else { return }
        loadFailed = false
        // Never destroy a user's store to recover from a load error.
        container.loadPersistentStores { _, error in
            if let error {
                AppLog.error("Persistent store could not be opened", error)
            }
            self.loadFailed = error != nil
            self.isReady = error == nil
        }
    }
}
