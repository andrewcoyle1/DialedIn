//
//  MockGymProfileServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

struct MockGymProfileServices: GymProfileServices {
    let local: LocalGymProfilePersistence
    let remote: RemoteGymProfileService
    
    init(delay: Double = 0, showError: Bool = false, profiles: [GymProfileModel] = GymProfileModel.mocks) {
        self.remote = MockGymProfileService(delay: delay, showError: showError, profiles: profiles)
        self.local = MockGymProfilePersistence(showError: showError, profiles: profiles)
    }
}
