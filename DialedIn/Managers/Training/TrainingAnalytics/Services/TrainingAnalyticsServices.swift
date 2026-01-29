//
//  TrainingAnalyticsServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

protocol TrainingAnalyticsServices {
    var remote: RemoteTrainingAnalyticsService { get }
    var local: LocalTrainingAnalyticsService { get }
}
