//
//  UserAuthInfo+Firebase.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/12/24.
//
import FirebaseAuth

extension UserAuthInfo {
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
        // Existing authenticated user from Firebase state is not considered a new user
        self.isNewUser = false
    }

}
