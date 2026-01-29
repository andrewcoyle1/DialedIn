//
//  ProductionUserServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistence
    
    @MainActor
    init() {
        self.remote = FirebaseUserService()
        self.local = FileManagerUserPersistence()
    }
}
