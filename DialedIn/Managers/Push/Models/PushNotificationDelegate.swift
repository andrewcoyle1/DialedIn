//
//  PushNotificationDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/02/2026.
//

import Foundation

struct PushNotificationDelegate {
    let identifier: String
    let title: String
    let subtitle: String
    let triggerDate: Date
    let sound: Bool
    let badge: Int?
    let repeats: Bool
    
    init(identifier: String, title: String, subtitle: String, triggerDate: Date, sound: Bool = true, badge: Int? = nil, repeats: Bool = false) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.triggerDate = triggerDate
        self.sound = sound
        self.badge = badge
        self.repeats = repeats
    }
}
