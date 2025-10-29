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
    
    private(set) var weightHistory: [WeightEntry] = []
    private(set) var isLoading: Bool = false
    
    init(services: UserWeightServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    // MARK: - Public Methods
    
    /// Log a new weight entry
    func logWeight(_ weightKg: Double, date: Date = Date(), notes: String? = nil, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let entry = WeightEntry(
            userId: userId,
            weightKg: weightKg,
            date: date,
            source: .manual,
            notes: notes
        )
        
        // Save to remote
        try await remote.saveWeightEntry(entry)
        
        // Save to local cache
        try await local.saveWeightEntry(entry)
        
        // Update local array
        weightHistory.append(entry)
        weightHistory.sort { $0.date > $1.date }
    }
    
    /// Get weight history with optional limit
    @discardableResult
    func getWeightHistory(userId: String, limit: Int? = nil) async throws -> [WeightEntry] {
        isLoading = true
        defer { isLoading = false }
        
        // Try local first
        if let cached = try? await local.getWeightHistory(userId: userId, limit: limit), !cached.isEmpty {
            weightHistory = cached
            return cached
        }
        
        // Fetch from remote
        let entries = try await remote.getWeightHistory(userId: userId, limit: limit)
        
        // Cache locally
        for entry in entries {
            try? await local.saveWeightEntry(entry)
        }
        
        weightHistory = entries
        return entries
    }
    
    /// Get the most recent weight entry
    func getLatestWeight(userId: String) async throws -> WeightEntry? {
        if let latest = weightHistory.first {
            return latest
        }
        
        let history = try await getWeightHistory(userId: userId, limit: 1)
        return history.first
    }
    
    /// Delete a weight entry
    func deleteWeightEntry(id: String, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Delete from remote
        try await remote.deleteWeightEntry(id: id, userId: userId)
        
        // Delete from local cache
        try await local.deleteWeightEntry(id: id, userId: userId)
        
        // Update local array
        weightHistory.removeAll { $0.id == id }
    }
    
    /// Refresh weight history from remote
    func refresh(userId: String) async throws {
        let entries = try await remote.getWeightHistory(userId: userId, limit: nil)
        
        // Update local cache
        for entry in entries {
            try? await local.saveWeightEntry(entry)
        }
        
        weightHistory = entries
    }
}
