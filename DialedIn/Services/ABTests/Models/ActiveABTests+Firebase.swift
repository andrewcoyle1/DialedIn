//
//  ActiveABTests+Firebase.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/12/2025.
//

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
