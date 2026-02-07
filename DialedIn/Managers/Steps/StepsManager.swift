//
//  StepsManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

import Foundation

@Observable
class StepsManager {
    private let local: LocalStepsPersistence
    private let remote: RemoteStepsService
    
    #if canImport(HealthKit)
    private let healthKit: HealthKitStepsService?
    private var lastUserIdForSync: String?
    private var lastUserCreationDate: Date?
    private var isHealthKitSyncInProgress = false
    private let healthKitLastSyncKey = "healthkit.steps.lastSyncDate"
    #endif

    private(set) var stepsHistory: [StepsModel] = []

    init(services: StepsServices) {
        self.remote = services.remote
        self.local = services.local
        #if canImport(HealthKit)
        self.healthKit = services.healthKit
        #endif
    }

    // MARK: CREATE
    func createStepsEntry(steps: StepsModel) async throws {
        try local.createStepsEntry(steps: steps)
        try await remote.createStepsEntry(steps: steps)
        #if canImport(HealthKit)
        lastUserIdForSync = steps.authorId
        await exportToHealthKitIfNeeded(steps: steps)
        #endif
    }

    // MARK: READ
    func readLocalStepsEntry(id: String) throws -> StepsModel {
        try local.readStepsEntry(id: id)
    }

    func readRemoteStepsEntry(userId: String, stepsId: String) async throws -> StepsModel {
        try await remote.readStepsEntry(userId: userId, stepsId: stepsId)
    }

    @discardableResult
    func readAllLocalStepsEntries() throws -> [StepsModel] {
        self.stepsHistory = try local.readAllLocalStepsEntries()
#if canImport(HealthKit)
        if let userId = lastUserIdForSync ?? stepsHistory.first?.authorId {
            Task { [weak self] in
                await self?.syncWithHealthKit(userId: userId)
            }
        }
#endif
        return self.stepsHistory
    }

    @discardableResult
    func readAllRemoteStepsEntries(userId: String, userCreationDate: Date? = nil) async throws -> [StepsModel] {
#if canImport(HealthKit)
        lastUserIdForSync = userId
        lastUserCreationDate = userCreationDate ?? lastUserCreationDate
        await syncWithHealthKit(userId: userId)
#endif
        let remoteSteps = try await remote.readAllStepsEntriesForAuthor(userId: userId)
        for steps in remoteSteps {
            do {
                try local.createStepsEntry(steps: steps)
            } catch {
                try? local.updateStepsEntry(steps: steps)
            }
        }
        self.stepsHistory = remoteSteps
        return self.stepsHistory
    }

    // MARK: UPDATE
    func updateStepsEntry(steps: StepsModel) async throws {
        try local.updateStepsEntry(steps: steps)
        try await remote.updateStepsEntry(steps: steps)
        // Update the in-memory cache to reflect the changes
        if let index = stepsHistory.firstIndex(where: { $0.id == steps.id }) {
            stepsHistory[index] = steps
        } else {
            // If entry not found in cache, refresh from local storage
            _ = try? readAllLocalStepsEntries()
        }
    }

    // MARK: DELETE
    func deleteStepsEntry(userId: String, stepsId: String) async throws {
        try local.deleteStepsEntry(id: stepsId)
        try await remote.deleteStepsEntry(userId: userId, stepsId: stepsId)
    }

    /// Clears all local Steps data. Does not delete remote data.
    func clearAllLocalStepsData() throws {
        try local.deleteAllLocalStepsEntries()
        stepsHistory = []
        #if canImport(HealthKit)
        UserDefaults.standard.removeObject(forKey: healthKitLastSyncKey)
        #endif
    }

    // MARK: Maintenance
    func dedupeStepsEntriesByDay(userId: String) async throws {
        let entries = try local.readAllLocalStepsEntries()
        let filteredEntries = entries.filter { $0.authorId == userId && $0.deletedAt == nil }
        guard !filteredEntries.isEmpty else { return }

        let entriesByDay = Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }

        var idsToDelete = Set<String>()
        for (_, dayEntries) in entriesByDay {
            // Only dedupe entries that have weightKg
            guard !dayEntries.isEmpty else { continue }
            
            guard let minEntry = dayEntries.min(by: { lhs, rhs in
                    return lhs.date < rhs.date
            }) else {
                continue
            }

            // Delete other entries with weightKg from the same day
            for entry in dayEntries where entry.id != minEntry.id {
                idsToDelete.insert(entry.id)
            }
        }

        for stepsId in idsToDelete {
            try local.deleteStepsEntry(id: stepsId)
            try await remote.deleteStepsEntry(userId: userId, stepsId: stepsId)
        }

        if let refreshed = try? local.readAllLocalStepsEntries() {
            stepsHistory = refreshed
        }
    }

#if canImport(HealthKit)
    // MARK: HealthKit Sync
    func syncWithHealthKit(userId: String) async {
        guard healthKit != nil else { return }
        guard !isHealthKitSyncInProgress else { return }
        isHealthKitSyncInProgress = true
        defer { isHealthKitSyncInProgress = false }

        do {
            try await importFromHealthKit(userId: userId)
        } catch {
            return
        }
    }

    /// Imports steps from HealthKit only when the local steps database is empty (one-time backfill).
    func backfillStepsFromHealthKit(userId: String, userCreationDate: Date? = nil) async {
        guard healthKit != nil else { return }
        guard !isHealthKitSyncInProgress else { return }
        let existingEntries = (try? local.readAllLocalStepsEntries()) ?? []
        guard existingEntries.isEmpty else { return }

        isHealthKitSyncInProgress = true
        defer { isHealthKitSyncInProgress = false }

        lastUserCreationDate = userCreationDate ?? lastUserCreationDate

        do {
            try await importFromHealthKit(userId: userId)
        } catch {
            return
        }
    }

    private func importFromHealthKit(userId: String) async throws {
        guard let healthKit else { return }

        let lastSync = lastHealthKitSyncDate()
        let earliestDate = lastUserCreationDate.map { Calendar.current.startOfDay(for: $0) }
        let samples = try await healthKit.readStepsSamples(since: lastSync, earliestDate: earliestDate)
        guard !samples.isEmpty else { return }

        let existingEntries = (try? local.readAllLocalStepsEntries()) ?? []
        let existingIds = Set(existingEntries.compactMap(\.healthKitId))
        let existingDayMaxs = Dictionary(grouping: existingEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }.compactMapValues { dayEntries in
            let maxEntry = dayEntries
                .filter { $0.authorId == userId && $0.deletedAt == nil }
                .max { lhs, rhs in
                    return lhs.number < rhs.number
                }
            return maxEntry?.number
        }

        var newestDate = lastSync
        for sample in samples {
            if newestDate == nil || sample.date > newestDate! {
                newestDate = sample.date
            }

            if existingIds.contains(sample.id) {
                continue
            }

            let sampleDay = Calendar.current.startOfDay(for: sample.date)
            if let existingDayMax = existingDayMaxs[sampleDay], existingDayMax >= sample.steps {
                continue
            }

            let steps = StepsModel(
                authorId: userId,
                number: sample.steps,
                date: sample.date,
                source: .healthkit,
                dateCreated: sample.date,
                dateModified: sample.date,
                healthKitId: sample.id
            )

            do {
                try local.createStepsEntry(steps: steps)
            } catch {
                try? local.updateStepsEntry(steps: steps)
            }

            do {
                try await remote.createStepsEntry(steps: steps)
            } catch {
                try? await remote.updateStepsEntry(steps: steps)
            }
        }

        if let newestDate {
            setLastHealthKitSyncDate(newestDate)
        }

        let refreshedEntries = (try? local.readAllLocalStepsEntries()) ?? existingEntries
        if let refreshed = try? local.readAllLocalStepsEntries() {
            stepsHistory = refreshed
        }
    }

    private func exportToHealthKitIfNeeded(steps: StepsModel) async {
        guard let healthKit else { return }
        guard steps.source != .healthkit, steps.healthKitId == nil else { return }

        do {
            let uuid = try await healthKit.saveStepsSample(steps: steps.number, date: steps.date)
            let updatedEntry = StepsModel(
                id: steps.id,
                authorId: steps.authorId,
                number: steps.number,
                date: steps.date,
                source: steps.source,
                dateCreated: steps.dateCreated,
                dateModified: steps.dateModified,
                deletedAt: steps.deletedAt,
                healthKitId: uuid
            )

            try local.updateStepsEntry(steps: updatedEntry)
            try await remote.updateStepsEntry(steps: updatedEntry)

            if let index = stepsHistory.firstIndex(where: { $0.id == updatedEntry.id }) {
                stepsHistory[index] = updatedEntry
            }
        } catch {
            return
        }
    }

    private func lastHealthKitSyncDate() -> Date? {
        UserDefaults.standard.object(forKey: healthKitLastSyncKey) as? Date
    }

    private func setLastHealthKitSyncDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: healthKitLastSyncKey)
    }

#endif
}
