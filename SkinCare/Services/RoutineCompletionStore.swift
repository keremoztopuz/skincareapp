//
//  RoutineCompletionStore.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 22.08.2026.
//

import Foundation

/// Tracks which routine steps were checked off, per calendar day and routine
/// time. UserDefaults-backed so ticks reset naturally at midnight and no
/// Core Data migration is needed.
final class RoutineCompletionStore {
    static let shared = RoutineCompletionStore()

    private let defaults = UserDefaults.standard
    private let keyPrefix = "routineCompletions"
    /// Retention window; the streak on the profile derives its cap from
    /// this so the two can never disagree.
    let keepDays = 7

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private init() {
        pruneOldEntries()
    }

    private func key(for date: Date, time: String) -> String {
        "\(keyPrefix).\(Self.dayFormatter.string(from: date)).\(time)"
    }

    func completedIDs(time: String, on date: Date = Date()) -> Set<UUID> {
        let stored = defaults.stringArray(forKey: key(for: date, time: time)) ?? []
        return Set(stored.compactMap(UUID.init(uuidString:)))
    }

    func isCompleted(_ id: UUID, time: String, on date: Date = Date()) -> Bool {
        completedIDs(time: time, on: date).contains(id)
    }

    func toggle(_ id: UUID, time: String, on date: Date = Date()) {
        var ids = completedIDs(time: time, on: date)
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        defaults.set(ids.map(\.uuidString), forKey: key(for: date, time: time))
    }

    /// Wipes every stored completion; used by "delete all data".
    func removeAll() {
        for storedKey in defaults.dictionaryRepresentation().keys where storedKey.hasPrefix("\(keyPrefix).") {
            defaults.removeObject(forKey: storedKey)
        }
    }

    /// Drops per-day keys older than `keepDays` so the store cannot grow
    /// forever. Also called before streak computation: the singleton's init
    /// runs once, and an app kept alive for weeks would otherwise never
    /// prune again.
    func pruneOldEntries() {
        guard let cutoff = Calendar.current.date(byAdding: .day, value: -keepDays, to: Date()) else { return }
        let cutoffDay = Self.dayFormatter.string(from: cutoff)
        for storedKey in defaults.dictionaryRepresentation().keys where storedKey.hasPrefix("\(keyPrefix).") {
            let parts = storedKey.split(separator: ".")
            guard parts.count >= 2 else { continue }
            let day = String(parts[1])
            if day < cutoffDay {
                defaults.removeObject(forKey: storedKey)
            }
        }
    }
}
