//
//  Constants.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import Foundation

struct Constants {
    
    static let randomImage = "https://picsum.photos/600/600"
    static let termsofServiceURL = "https://www.apple.com"
    static let privacyPolicyURL = "https://www.apple.com"
    
    static var mixpanelDistinctId: String? {
        #if MOCK
        return nil
        #else
        return MixpanelService.distinctId
        #endif
    }
    
    static var firebaseAnalyticsAppInstanceID: String? {
        #if MOCK
        return nil
        #else
        return FirebaseAnalyticsService.appInstanceID
        #endif
    }

    // App Group identifier for sharing data between app and widget extension
    static let appGroupIdentifier = "group.com.dialedin.app"
    
    /// Map exercise template names to bundled asset names for Live Activity
    /// Returns nil for exercises without bundled images
    static func exerciseImageName(for exerciseName: String) -> String? {
        let normalized = exerciseName
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Direct mapping dictionary for pre-bundled exercise images
        let exerciseImageMap: [String: String] = [
            "barbell bench press": "BarbellBenchPress",
            "barbell incline bench press": "BarbellInclineBenchPress",
            "barbell romanian deadlift": "Barbell_RomanianDeadlift",
            "barbell squat": "BarbellSquat",
            "barbell back squat": "BarbellSquat",
            "barbell sumo deadlift": "BarbellSumoDeadlift",
            "bulgarian split squat": "BulgarianSplitSquat",
            "dumbbell bulgarian split squat": "BulgarianSplitSquat",
            "cable bicep curl (straight bar)": "CableBicepCurl_StraightBar",
            "cable biceps curl (straight bar)": "CableBicepCurl_StraightBar",
            "cable pushdown (straight bar)": "CablePushdown_StraightBar",
            "cable tricep pushdown (straight bar)": "CablePushdown_StraightBar",
            "calf press on leg press": "CalfPressOnLegPress",
            "seated calf press": "CalfPressOnLegPress",
            "chest dip": "ChestDip",
            "dips": "ChestDip",
            "dumbbell incline fly": "Dumbbell_InclineFlyChest",
            "dumbbell incline chest fly": "Dumbbell_InclineFlyChest",
            "dumbbell bench press": "DumbbellBenchPress",
            "dumbbell seated shoulder press": "DumbbellSeatedShoulderPress",
            "ez barbell preacher curl": "EZBarbell_PreacherCurl",
            "preacher curl": "EZBarbell_PreacherCurl",
            "hack squat": "HackSquat",
            "lat prayer (straight bar)": "LatPrayer_StraightBar",
            "lat pulldown (straight bar)": "LatPrayer_StraightBar",
            "lying leg curl": "LyingLegCurl",
            "leg curl": "LyingLegCurl",
            "overhead extension (straight bar)": "OverheadExtensionStraightBar",
            "cable overhead tricep extension (straight bar)": "OverheadExtensionStraightBar",
            "reverse fly": "ReverseFly",
            "reverse pec deck fly": "ReverseFly",
            "seated leg extension": "SeatedLegExtension",
            "leg extension": "SeatedLegExtension",
            "seated row": "SeatedRow",
            "cable seated row": "SeatedRow",
            "machine seated row": "SeatedRow",
            "single arm row": "SingleArmRow",
            "dumbbell single arm row": "SingleArmRow",
            "one arm row": "SingleArmRow",
            "standing lateral raise (cable)": "StandingLatRaise_Cable",
            "cable lateral raise": "StandingLatRaise_Cable",
            "t-bar row": "TBarRow",
            "t bar row": "TBarRow"
        ]
        
        return exerciseImageMap[normalized]
    }
}
