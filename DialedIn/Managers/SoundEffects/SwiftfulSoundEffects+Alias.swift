//
//  SwiftfulSoundEffects+Alias.swift
//  ArchitectureProject
//
//  Created by Nick Sarno on 1/12/25.
//

import SwiftfulSoundEffects

typealias SoundEffectManager = SwiftfulSoundEffects.SoundEffectManager

extension SoundEffectLogType {
    
    var type: LogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .analytic
        case .warning:
            return .warning
        case .severe:
            return .severe
        }
    }
    
}
extension LogManager: @retroactive SoundEffectLogger {
    
    public func trackEvent(event: any SoundEffectLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
    
}

extension CoreInteractor {
    // MARK: Sound Effects

    func prepareSoundEffect(sound: SoundEffectFile, simultaneousPlayers: Int = 1) {
        Task {
            await soundEffectManager.prepare(url: sound.url, simultaneousPlayers: simultaneousPlayers, volume: 1)
        }
    }

    func tearDownSoundEffect(sound: SoundEffectFile) {
        Task {
            await soundEffectManager.tearDown(url: sound.url)
        }
    }

    func playSoundEffect(sound: SoundEffectFile) {
        Task {
            await soundEffectManager.play(url: sound.url)
        }
    }

}
