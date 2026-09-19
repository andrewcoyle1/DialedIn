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
    
    var fileName: String {
        switch self {
        case .sample:
            return "Sample.wav"
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
