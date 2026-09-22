//
//  RecentSearchManagerTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 22/09/2026.
//

import Testing
import Foundation
@testable import DialedIn

/// The recent search list behind the search field.
///
/// It is a static store over `UserDefaults.standard` under a fixed key, so there is nothing to
/// inject and nothing to isolate — the suite is serialized and each test restores whatever was
/// there before it ran.
@MainActor
@Suite(.serialized)
struct RecentSearchManagerTests {

    private static let userDefaultsKey = "search_recent_queries"

    /// Runs `body` against an empty list and puts the real one back afterwards, so a developer's
    /// own simulator history survives the run.
    private func withEmptyHistory(_ body: () -> Void) {
        let existing = UserDefaults.standard.data(forKey: Self.userDefaultsKey)
        RecentSearchManager.clearRecentSearches()
        defer {
            if let existing {
                UserDefaults.standard.set(existing, forKey: Self.userDefaultsKey)
            } else {
                RecentSearchManager.clearRecentSearches()
            }
        }
        body()
    }

    // MARK: - Ordering

    @Test("Test There Are No Recent Searches To Begin With")
    func testThereAreNoRecentSearchesToBeginWith() {
        withEmptyHistory {
            #expect(RecentSearchManager.recentSearchQueries.isEmpty)
        }
    }

    @Test("Test The Newest Search Comes First")
    func testTheNewestSearchComesFirst() {
        withEmptyHistory {
            RecentSearchManager.addRecentSearch(query: "oats")
            RecentSearchManager.addRecentSearch(query: "milk")
            RecentSearchManager.addRecentSearch(query: "eggs")

            #expect(RecentSearchManager.recentSearchQueries == ["eggs", "milk", "oats"])
        }
    }

    // MARK: - De-duplication

    /// Searching the same thing twice moves it up rather than listing it twice, which is what
    /// stops a list of ten from being one word repeated.
    @Test("Test Searching The Same Thing Again Moves It To The Front")
    func testSearchingTheSameThingAgainMovesItToTheFront() {
        withEmptyHistory {
            RecentSearchManager.addRecentSearch(query: "oats")
            RecentSearchManager.addRecentSearch(query: "milk")
            RecentSearchManager.addRecentSearch(query: "oats")

            #expect(RecentSearchManager.recentSearchQueries == ["oats", "milk"])
        }
    }

    /// Case is how the user typed it, not a different search.
    @Test("Test A Differently Cased Repeat Is Still The Same Search")
    func testADifferentlyCasedRepeatIsStillTheSameSearch() {
        withEmptyHistory {
            RecentSearchManager.addRecentSearch(query: "Oats")
            RecentSearchManager.addRecentSearch(query: "milk")
            RecentSearchManager.addRecentSearch(query: "OATS")

            // One entry, spelled the way it was typed most recently.
            #expect(RecentSearchManager.recentSearchQueries == ["OATS", "milk"])
        }
    }

    // MARK: - What is not stored

    @Test("Test An Empty Search Is Not Stored")
    func testAnEmptySearchIsNotStored() {
        withEmptyHistory {
            RecentSearchManager.addRecentSearch(query: "")
            RecentSearchManager.addRecentSearch(query: "   \n ")

            #expect(RecentSearchManager.recentSearchQueries.isEmpty)
        }
    }

    @Test("Test Surrounding Whitespace Is Trimmed Off")
    func testSurroundingWhitespaceIsTrimmedOff() {
        withEmptyHistory {
            RecentSearchManager.addRecentSearch(query: "  oats  ")
            // And the trimmed form is what a later untrimmed repeat matches against.
            RecentSearchManager.addRecentSearch(query: "oats")

            #expect(RecentSearchManager.recentSearchQueries == ["oats"])
        }
    }

    // MARK: - The bound

    /// The list is capped, so a heavy user's defaults do not grow without limit — and the ten it
    /// keeps are the ten most recent.
    @Test("Test The List Stops At Ten And Keeps The Newest")
    func testTheListStopsAtTenAndKeepsTheNewest() {
        withEmptyHistory {
            for index in 1...25 {
                RecentSearchManager.addRecentSearch(query: "query-\(index)")
            }

            let queries = RecentSearchManager.recentSearchQueries
            #expect(queries.count == 10)
            #expect(queries.first == "query-25")
            #expect(queries.last == "query-16")
        }
    }

    // MARK: - Clearing

    @Test("Test Clearing Removes Every Recent Search")
    func testClearingRemovesEveryRecentSearch() {
        withEmptyHistory {
            RecentSearchManager.addRecentSearch(query: "oats")
            RecentSearchManager.addRecentSearch(query: "milk")
            #expect(RecentSearchManager.recentSearchQueries.count == 2)

            RecentSearchManager.clearRecentSearches()

            #expect(RecentSearchManager.recentSearchQueries.isEmpty)
        }
    }

    /// Anything that is not an encoded list of strings reads as no history rather than crashing
    /// the search screen.
    @Test("Test Unreadable Stored History Reads As Nothing")
    func testUnreadableStoredHistoryReadsAsNothing() {
        withEmptyHistory {
            UserDefaults.standard.set(Data("not json".utf8), forKey: Self.userDefaultsKey)

            #expect(RecentSearchManager.recentSearchQueries.isEmpty)

            // And the next search still lands, rather than being lost behind the bad value.
            RecentSearchManager.addRecentSearch(query: "oats")
            #expect(RecentSearchManager.recentSearchQueries == ["oats"])
        }
    }
}
