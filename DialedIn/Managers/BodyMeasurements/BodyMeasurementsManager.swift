//
//  BodyMeasurementsManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

@Observable
class BodyMeasurementsManager {
    private let remote: RemoteBodyMeasurementService
    private let local: LocalBodyMeasurementService
#if canImport(HealthKit)
    private let healthKit: HealthKitWeightService?
    private var lastUserIdForSync: String?
    private var isHealthKitSyncInProgress = false
    private let healthKitLastSyncKey = "healthkit.weight.lastSyncDate"
    private let healthKitBodyFatLastSyncKey = "healthkit.bodyfat.lastSyncDate"
#endif

    private(set) var measurementHistory: [BodyMeasurementEntry] = []

    init(services: BodyMeasurementServices) {
        self.remote = services.remote
        self.local = services.local
#if canImport(HealthKit)
        self.healthKit = services.healthKit
#endif

        _ = try? self.readAllLocalWeightEntries()
    }

    // MARK: CREATE
    func createWeightEntry(weightEntry: BodyMeasurementEntry) async throws {
        try local.createWeightEntry(weightEntry: weightEntry)
        try await remote.createWeightEntry(entry: weightEntry)
#if canImport(HealthKit)
        lastUserIdForSync = weightEntry.authorId
        await exportToHealthKitIfNeeded(entry: weightEntry)
#endif
    }

    // MARK: READ
    func readLocalWeightEntry(id: String) throws -> BodyMeasurementEntry {
        try local.readWeightEntry(id: id)
    }

    func readRemoteWeightEntry(userId: String, entryId: String) async throws -> BodyMeasurementEntry {
        try await remote.readWeightEntry(userId: userId, entryId: entryId)
    }

    @discardableResult
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry] {
        self.measurementHistory = try local.readWeightEntries()
#if canImport(HealthKit)
        if let userId = lastUserIdForSync ?? measurementHistory.first?.authorId {
            Task { [weak self] in
                await self?.syncWithHealthKit(userId: userId)
            }
        }
#endif
        return self.measurementHistory
    }

    @discardableResult
    func readAllRemoteWeightEntries(userId: String) async throws -> [BodyMeasurementEntry] {
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
        self.measurementHistory = remoteEntries
        return self.measurementHistory
    }

    // MARK: UPDATE
    func updateWeightEntry(entry: BodyMeasurementEntry) async throws {
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
            // Only dedupe entries that have weightKg
            let entriesWithWeight = dayEntries.filter { $0.weightKg != nil }
            guard !entriesWithWeight.isEmpty else { continue }
            
            guard let minEntry = entriesWithWeight.min(by: { lhs, rhs in
                guard let lhsWeight = lhs.weightKg, let rhsWeight = rhs.weightKg else {
                    return false
                }
                if lhsWeight == rhsWeight {
                    return lhs.date < rhs.date
                }
                return lhsWeight < rhsWeight
            }) else {
                continue
            }

            // Delete other entries with weightKg from the same day
            for entry in entriesWithWeight where entry.id != minEntry.id {
                idsToDelete.insert(entry.id)
            }
        }

        for entryId in idsToDelete {
            try local.deleteWeightEntry(id: entryId)
            try await remote.deleteWeightEntry(userId: userId, entryId: entryId)
        }

        if let refreshed = try? local.readWeightEntries() {
            measurementHistory = refreshed
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
                .filter { $0.authorId == userId && $0.deletedAt == nil && $0.weightKg != nil }
                .min { lhs, rhs in
                    guard let lhsWeight = lhs.weightKg, let rhsWeight = rhs.weightKg else {
                        return false
                    }
                    return lhsWeight < rhsWeight
                }
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

            let entry = BodyMeasurementEntry(
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
            measurementHistory = refreshed
        }
    }

    private func importBodyFatFromHealthKit(
        userId: String,
        existingEntries: [BodyMeasurementEntry],
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

            let updatedEntry = BodyMeasurementEntry(
                id: entryToUpdate.id,
                authorId: entryToUpdate.authorId,
                weightKg: entryToUpdate.weightKg,
                bodyFatPercentage: sample.bodyFatPercentage,
                neckCircumference: entryToUpdate.neckCircumference,
                shoulderCircumference: entryToUpdate.shoulderCircumference,
                bustCircumference: entryToUpdate.bustCircumference,
                chestCircumference: entryToUpdate.chestCircumference,
                waistCircumference: entryToUpdate.waistCircumference,
                hipCircumference: entryToUpdate.hipCircumference,
                leftBicepCircumference: entryToUpdate.leftBicepCircumference,
                rightBicepCircumference: entryToUpdate.rightBicepCircumference,
                leftForearmCircumference: entryToUpdate.leftForearmCircumference,
                rightForearmCircumference: entryToUpdate.rightForearmCircumference,
                leftWristCircumference: entryToUpdate.leftWristCircumference,
                rightWristCircumference: entryToUpdate.rightWristCircumference,
                leftThighCircumference: entryToUpdate.leftThighCircumference,
                rightThighCircumference: entryToUpdate.rightThighCircumference,
                leftCalfCircumference: entryToUpdate.leftCalfCircumference,
                rightCalfCircumference: entryToUpdate.rightCalfCircumference,
                leftAnkleCircumference: entryToUpdate.leftAnkleCircumference,
                rightAnkleCircumference: entryToUpdate.rightAnkleCircumference,
                progressPhotoURLs: entryToUpdate.progressPhotoURLs,
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

    private func exportToHealthKitIfNeeded(entry: BodyMeasurementEntry) async {
        guard let healthKit else { return }
        guard entry.source != .healthkit, entry.healthKitUUID == nil else { return }
        guard let weightKg = entry.weightKg else { return }

        do {
            let uuid = try await healthKit.saveWeightSample(weightKg: weightKg, date: entry.date)
            let updatedEntry = BodyMeasurementEntry(
                id: entry.id,
                authorId: entry.authorId,
                weightKg: weightKg,
                bodyFatPercentage: entry.bodyFatPercentage,
                neckCircumference: entry.neckCircumference,
                shoulderCircumference: entry.shoulderCircumference,
                bustCircumference: entry.bustCircumference,
                chestCircumference: entry.chestCircumference,
                waistCircumference: entry.waistCircumference,
                hipCircumference: entry.hipCircumference,
                leftBicepCircumference: entry.leftBicepCircumference,
                rightBicepCircumference: entry.rightBicepCircumference,
                leftForearmCircumference: entry.leftForearmCircumference,
                rightForearmCircumference: entry.rightForearmCircumference,
                leftWristCircumference: entry.leftWristCircumference,
                rightWristCircumference: entry.rightWristCircumference,
                leftThighCircumference: entry.leftThighCircumference,
                rightThighCircumference: entry.rightThighCircumference,
                leftCalfCircumference: entry.leftCalfCircumference,
                rightCalfCircumference: entry.rightCalfCircumference,
                leftAnkleCircumference: entry.leftAnkleCircumference,
                rightAnkleCircumference: entry.rightAnkleCircumference,
                progressPhotoURLs: entry.progressPhotoURLs,
                date: entry.date,
                source: entry.source,
                notes: entry.notes,
                dateCreated: entry.dateCreated,
                deletedAt: entry.deletedAt,
                healthKitUUID: uuid
            )

            try local.updateWeightEntry(entry: updatedEntry)
            try await remote.updateWeightEntry(entry: updatedEntry)

            if let index = measurementHistory.firstIndex(where: { $0.id == updatedEntry.id }) {
                measurementHistory[index] = updatedEntry
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
