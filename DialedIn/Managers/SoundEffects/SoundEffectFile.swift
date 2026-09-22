//
//  SoundEffectFile.swift
//  ArchitectureProject
//
//  Created by Nick Sarno on 1/12/25.
//
import Foundation

// Use this to register sound effects in the application.
// Add the file to the bundle (ie. in SoundEffectFiles folder) and create an enum case!

enum SoundEffectFile: String, Equatable {
    case sample
    /// Played when a rest timer runs out, if `WorkoutSettings.restTimerPlaySound` is on. The audio
    /// file is not in the bundle yet, so this is silent until one is added under that name — `url`
    /// below returns nil rather than crashing, and the rest-end haptic still fires.
    case restComplete

    var fileName: String {
        switch self {
        case .sample:
            return "Sample.wav"
        case .restComplete:
            return "RestComplete.wav"
        }
    }
    
    /// Force-unwrapped `Bundle.main.path(forResource:)` before. `Sample.wav` is not in the bundle —
    /// it is a leftover from the template this project started from — so the one call that would
    /// have played a sound would have crashed instead. Optional, so a missing file is silence.
    var url: URL? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else { return nil }
        return URL(fileURLWithPath: path)
    }
}
