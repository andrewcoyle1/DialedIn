//
//  ProductionLocalUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

struct ProductionLocalUserWeightService: LocalUserWeightService {
    
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "weight_entries_cache"
    
    private func getCacheKey(userId: String) -> String {
        "\(cacheKey)_\(userId)"
    }
    
    func saveWeightEntry(_ entry: WeightEntry) async throws {
        var entries = try await getWeightHistory(userId: entry.userId, limit: nil)
        
        // Remove existing entry with same ID if present
        entries.removeAll { $0.id == entry.id }
        
        // Add new entry
        entries.append(entry)
        
        // Sort by date descending
        entries.sort { $0.date > $1.date }
        
        // Keep only last 30 entries
        let limitedEntries = Array(entries.prefix(30))
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(limitedEntries) {
            userDefaults.set(encoded, forKey: getCacheKey(userId: entry.userId))
        }
    }
    
    func getWeightHistory(userId: String, limit: Int?) async throws -> [WeightEntry] {
        guard let data = userDefaults.data(forKey: getCacheKey(userId: userId)),
              let entries = try? JSONDecoder().decode([WeightEntry].self, from: data) else {
            return []
        }
        
        if let limit = limit {
            return Array(entries.prefix(limit))
        }
        
        return entries
    }
    
    func deleteWeightEntry(id: String, userId: String) async throws {
        var entries = try await getWeightHistory(userId: userId, limit: nil)
        entries.removeAll { $0.id == id }
        
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: getCacheKey(userId: userId))
        }
    }
    
    func clearCache(userId: String) async throws {
        userDefaults.removeObject(forKey: getCacheKey(userId: userId))
    }
}
