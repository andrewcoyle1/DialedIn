//
//  LiveActivityManager+Events.swift
//  DialedIn
//
//  Split out of LiveActivityManager.swift, which had reached the file-length limit.
//

import Foundation
#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)

enum LiveActivityError: LocalizedError {
    case noUpdatableActivity

    var errorDescription: String? {
        switch self {
        case .noUpdatableActivity:
            return "No active or stale Live Activity to update"
        }
    }
}

// MARK: Events
extension LiveActivityManager {
    enum Event: LoggableEvent {
        case startLiveActivityStart
        case startLiveActivitySuccess
        case startLiveActivityFail(error: Error)
        case liveActivitiesNotEnabled
        case updateLiveActivityStart
        case updateLiveActivitySuccess
        case updateLiveActivityFail(error: Error)
        case endLiveActivityStart
        case endLiveActivitySuccess

        var eventName: String {
            switch self {
            case .startLiveActivityStart:       return "LiveActivityMan_StartLiveActiviey_Start"
            case .startLiveActivitySuccess:     return "LiveActivityMan_StartLiveActiviey_Success"
            case .startLiveActivityFail:        return "LiveActivityMan_StartLiveActiviey_Fail"
            case .liveActivitiesNotEnabled:     return "LiveActivityMan_LiveActivitiesNotEnabled"
            case .updateLiveActivityStart:      return "LiveActivityMan_UpdateLiveActivity_Start"
            case .updateLiveActivitySuccess:    return "LiveActivityMan_UpdateLiveActivity_Success"
            case .updateLiveActivityFail:       return "LiveActivityMan_UpdateLiveActivity_Fail"
            case .endLiveActivityStart:         return "LiveActivityMan_EndLiveActivity_Start"
            case .endLiveActivitySuccess:       return "LiveActivityMan_EndLiveActivity_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .startLiveActivityFail(error: let error), .updateLiveActivityFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .startLiveActivityFail, .updateLiveActivityFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#endif
