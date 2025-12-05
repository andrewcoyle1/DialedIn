//
//  ActiveABTests.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/12/2025.
//

import Foundation

struct ActiveABTests: Codable {
    private(set) var notificationsTest: Bool
    
    init(notificationsTest: Bool? = nil) {
        self.notificationsTest = notificationsTest ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case notificationsTest = "_20251205_notifications_test"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.notificationsTest.rawValue)": notificationsTest
        ]
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(notificationsTest newValue: Bool) {
        notificationsTest = newValue
    }
}

// MARK: Remote Config

import FirebaseRemoteConfigInternal

extension ActiveABTests {
    init(config: RemoteConfig) {
        let notificationsTest = config.configValue(forKey: ActiveABTests.CodingKeys.notificationsTest.rawValue).boolValue
        self.notificationsTest = notificationsTest
    }
    
    // Converted to a NSObject dictionary to setDefaults within FirebaseABTestService
    var asNSObjectDictionary: [String: NSObject]? {
        [
            CodingKeys.notificationsTest.rawValue: notificationsTest as NSObject
        ]
    }
}
