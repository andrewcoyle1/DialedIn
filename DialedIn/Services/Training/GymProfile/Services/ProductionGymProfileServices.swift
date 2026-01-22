//
//  ProductionGymProfileServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

struct ProductionGymProfileServices: GymProfileServices {
    
    let local: LocalGymProfilePersistence
    let remote: RemoteGymProfileService
    
    init() {
        self.local = SwiftGymProfilePersistence()
        self.remote = FirebaseGymProfileService()
    }
}
