//
//  UserWeightManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

@Observable
class UserWeightManager {
    private let remote: RemoteUserWeightService
    private let local: LocalUserWeightService
    #if canImport(HealthKit)
    private let healthKit: HealthKitWeightService?
    private var lastUserIdForSync: String?
    private var isHealthKitSyncInProgress = false
    private let healthKitLastSyncKey = "healthkit.weight.lastSyncDate"
    private let healthKitBodyFatLastSyncKey = "healthkit.bodyfat.lastSyncDate"
    #endif
    
    private(set) var weightHistory: [WeightEntry] = []

    init(services: UserWeightServices) {
        self.remote = services.remote
        self.local = services.local
        #if canImport(HealthKit)
        self.healthKit = services.healthKit
        #endif
        
        _ = try? self.readAllLocalWeightEntries()
    }
    
    // MARK: CREATE
    func createWeightEntry(weightEntry: WeightEntry) async throws {
        try local.createWeightEntry(weightEntry: weightEntry)
        try await remote.createWeightEntry(entry: weightEntry)
        #if canImport(HealthKit)
        lastUserIdForSync = weightEntry.authorId
        await exportToHealthKitIfNeeded(entry: weightEntry)
        #endif
    }
    
    // MARK: READ
    func readLocalWeightEntry(id: String) throws -> WeightEntry {
        try local.readWeightEntry(id: id)
    }
    
    func readRemoteWeightEntry(userId: String, entryId: String) async throws -> WeightEntry {
        try await remote.readWeightEntry(userId: userId, entryId: entryId)
    }
    
    @discardableResult
    func readAllLocalWeightEntries() throws -> [WeightEntry] {
        self.weightHistory = try local.readWeightEntries()
        #if canImport(HealthKit)
        if let userId = lastUserIdForSync ?? weightHistory.first?.authorId {
            Task { [weak self] in
                await self?.syncWithHealthKit(userId: userId)
            }
        }
        #endif
        return self.weightHistory
    }
    
    @discardableResult
    func readAllRemoteWeightEntries(userId: String) async throws -> [WeightEntry] {
#if canImport(HealthKit)
        lastUserIdForSync = userId
        await syncWithHealthKit(userId: userId)
#endif
        let remoteEntries = try await remote.readAllWeightEntriesForAuthor(userId: userId)
        for entry in remoteEntries {
            do {
                try local.createWeightEntry(weightEntry: entry)
            } catch {
                try? local.updateWeightEntry(entry: entry)
            }
        }
        self.weightHistory = remoteEntries
        return self.weightHistory
    }
    
    // MARK: UPDATE
    func updateWeightEntry(entry: WeightEntry) async throws {
        try local.updateWeightEntry(entry: entry)
        try await remote.updateWeightEntry(entry: entry)
    }
    
    // MARK: DELETE
    func deleteWeightEntry(userId: String, entryId: String) async throws {
        try local.deleteWeightEntry(id: entryId)
        try await remote.deleteWeightEntry(userId: userId, entryId: entryId)
    }

    // MARK: Maintenance
    func dedupeWeightEntriesByDay(userId: String) async throws {
        let entries = try local.readWeightEntries()
        let filteredEntries = entries.filter { $0.authorId == userId && $0.deletedAt == nil }
        guard !filteredEntries.isEmpty else { return }

        let entriesByDay = Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }

        var idsToDelete = Set<String>()
        for (_, dayEntries) in entriesByDay {
            guard let minEntry = dayEntries.min(by: { lhs, rhs in
                if lhs.weightKg == rhs.weightKg {
                    return lhs.date < rhs.date
                }
                return lhs.weightKg < rhs.weightKg
            }) else {
                continue
            }

            for entry in dayEntries where entry.id != minEntry.id {
                idsToDelete.insert(entry.id)
            }
        }

        for entryId in idsToDelete {
            try local.deleteWeightEntry(id: entryId)
            try await remote.deleteWeightEntry(userId: userId, entryId: entryId)
        }

        if let refreshed = try? local.readWeightEntries() {
            weightHistory = refreshed
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

    func backfillBodyFatFromHealthKit(userId: String) async {
        guard healthKit != nil else { return }
        guard !isHealthKitSyncInProgress else { return }
        isHealthKitSyncInProgress = true
        defer { isHealthKitSyncInProgress = false }

        do {
            let existingEntries = (try? local.readWeightEntries()) ?? []
            try await importBodyFatFromHealthKit(userId: userId, existingEntries: existingEntries, forceFullSync: true)
        } catch {
            return
        }
    }

    private func importFromHealthKit(userId: String) async throws {
        guard let healthKit else { return }

        let lastSync = lastHealthKitSyncDate()
        let samples = try await healthKit.readWeightSamples(since: lastSync)
        guard !samples.isEmpty else { return }

        let samplesByDay = Dictionary(grouping: samples) { sample in
            Calendar.current.startOfDay(for: sample.date)
        }
        let consolidatedSamples = samplesByDay
            .compactMap { (_, daySamples) in
                daySamples.min { $0.weightKg < $1.weightKg }
            }

        let existingEntries = (try? local.readWeightEntries()) ?? []
        let existingUUIDs = Set(existingEntries.compactMap(\.healthKitUUID))
        let existingDayMins = Dictionary(grouping: existingEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }.compactMapValues { dayEntries in
            let minEntry = dayEntries
                .filter { $0.authorId == userId && $0.deletedAt == nil }
                .min { $0.weightKg < $1.weightKg }
            return minEntry?.weightKg
        }

        var newestDate = lastSync
        for sample in consolidatedSamples {
            if newestDate == nil || sample.date > newestDate! {
                newestDate = sample.date
            }

            if existingUUIDs.contains(sample.uuid) {
                continue
            }

            let sampleDay = Calendar.current.startOfDay(for: sample.date)
            if let existingDayMin = existingDayMins[sampleDay], existingDayMin <= sample.weightKg {
                continue
            }

            let entry = WeightEntry(
                authorId: userId,
                weightKg: sample.weightKg,
                date: sample.date,
                source: .healthkit,
                notes: nil,
                dateCreated: sample.date,
                deletedAt: nil,
                healthKitUUID: sample.uuid
            )

            do {
                try local.createWeightEntry(weightEntry: entry)
            } catch {
                try? local.updateWeightEntry(entry: entry)
            }

            do {
                try await remote.createWeightEntry(entry: entry)
            } catch {
                try? await remote.updateWeightEntry(entry: entry)
            }

        }

        if let newestDate {
            setLastHealthKitSyncDate(newestDate)
        }

        let refreshedEntries = (try? local.readWeightEntries()) ?? existingEntries
        try await importBodyFatFromHealthKit(
            userId: userId,
            existingEntries: refreshedEntries,
            forceFullSync: refreshedEntries.contains { $0.source == .healthkit && $0.deletedAt == nil && $0.bodyFatPercentage == nil }
        )

        if let refreshed = try? local.readWeightEntries() {
            weightHistory = refreshed
        }
    }

    private func importBodyFatFromHealthKit(
        userId: String,
        existingEntries: [WeightEntry],
        forceFullSync: Bool
    ) async throws {
        guard let healthKit else { return }

        let since = forceFullSync ? nil : lastHealthKitBodyFatSyncDate()
        let samples = try await healthKit.readBodyFatSamples(since: since)
        guard !samples.isEmpty else { return }

        let samplesByDay = Dictionary(grouping: samples) { sample in
            Calendar.current.startOfDay(for: sample.date)
        }
        let consolidatedSamples = samplesByDay
            .compactMap { (_, daySamples) in
                daySamples.max { $0.date < $1.date }
            }

        var newestDate = since
        let entriesByDay = Dictionary(grouping: existingEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }

        for sample in consolidatedSamples {
            if newestDate == nil || sample.date > newestDate! {
                newestDate = sample.date
            }

            let sampleDay = Calendar.current.startOfDay(for: sample.date)
            guard let dayEntries = entriesByDay[sampleDay] else { continue }
            guard let entryToUpdate = dayEntries.first(where: {
                $0.authorId == userId && $0.deletedAt == nil && $0.source == .healthkit
            }) else { continue }
            guard entryToUpdate.bodyFatPercentage == nil else { continue }

            let updatedEntry = WeightEntry(
                id: entryToUpdate.id,
                authorId: entryToUpdate.authorId,
                weightKg: entryToUpdate.weightKg,
                bodyFatPercentage: sample.bodyFatPercentage,
                date: entryToUpdate.date,
                source: entryToUpdate.source,
                notes: entryToUpdate.notes,
                dateCreated: entryToUpdate.dateCreated,
                deletedAt: entryToUpdate.deletedAt,
                healthKitUUID: entryToUpdate.healthKitUUID
            )

            do {
                try local.updateWeightEntry(entry: updatedEntry)
                try await remote.updateWeightEntry(entry: updatedEntry)
            } catch {
                continue
            }
        }

        if let newestDate {
            setLastHealthKitBodyFatSyncDate(newestDate)
        }
    }

    private func exportToHealthKitIfNeeded(entry: WeightEntry) async {
        guard let healthKit else { return }
        guard entry.source != .healthkit, entry.healthKitUUID == nil else { return }

        do {
            let uuid = try await healthKit.saveWeightSample(weightKg: entry.weightKg, date: entry.date)
            let updatedEntry = WeightEntry(
                id: entry.id,
                authorId: entry.authorId,
                weightKg: entry.weightKg,
                bodyFatPercentage: entry.bodyFatPercentage,
                date: entry.date,
                source: entry.source,
                notes: entry.notes,
                dateCreated: entry.dateCreated,
                deletedAt: entry.deletedAt,
                healthKitUUID: uuid
            )

            try local.updateWeightEntry(entry: updatedEntry)
            try await remote.updateWeightEntry(entry: updatedEntry)

            if let index = weightHistory.firstIndex(where: { $0.id == updatedEntry.id }) {
                weightHistory[index] = updatedEntry
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

    private func lastHealthKitBodyFatSyncDate() -> Date? {
        UserDefaults.standard.object(forKey: healthKitBodyFatLastSyncKey) as? Date
    }

    private func setLastHealthKitBodyFatSyncDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: healthKitBodyFatLastSyncKey)
    }
#endif
}
