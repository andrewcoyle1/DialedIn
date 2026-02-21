//
//  GymProfileServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

@MainActor
protocol GymProfileServices {
    
    var remote: RemoteGymProfileService { get }
    var local: LocalGymProfilePersistence { get }
}
