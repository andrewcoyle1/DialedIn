//
//  RecentSearchManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/02/2026.
//

import Foundation

enum RecentSearchManager {
    private static let maxQueries = 10
    private static let userDefaultsKey = "search_recent_queries"
    private static let userDefaults = UserDefaults.standard

    static var recentSearchQueries: [String] {
        guard let data = userDefaults.data(forKey: userDefaultsKey),
              let queries = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return queries
    }

    static func addRecentSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var queries = recentSearchQueries
        queries.removeAll { $0.lowercased() == trimmed.lowercased() }
        queries.insert(trimmed, at: 0)
        queries = Array(queries.prefix(maxQueries))

        if let data = try? JSONEncoder().encode(queries) {
            userDefaults.set(data, forKey: userDefaultsKey)
        }
    }

    static func clearRecentSearches() {
        userDefaults.removeObject(forKey: userDefaultsKey)
    }
}
