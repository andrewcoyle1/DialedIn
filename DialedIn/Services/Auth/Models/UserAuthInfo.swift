//
//  UserAuthInfo.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/12/24.
//
import SwiftUI

struct UserAuthInfo: Sendable, Codable, Equatable {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?
    let isNewUser: Bool

    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil,
        isNewUser: Bool
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.isNewUser = isNewUser
    }
    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
        case isNewUser = "is_new_user"
    }

    static func mock(isAnonymous: Bool = false) -> Self {
        UserAuthInfo(
            uid: "mock_user_123",
            email: "hello@swiftful-thinking.com",
            isAnonymous: isAnonymous,
            creationDate: .now,
            lastSignInDate: .now,
            isNewUser: true
        )
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "uauth_\(CodingKeys.uid.rawValue)": uid,
            "uauth_\(CodingKeys.email.rawValue)": email,
            "uauth_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "uauth_\(CodingKeys.creationDate.rawValue)": creationDate,
            "uauth_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "uauth_\(CodingKeys.isNewUser.rawValue)": isNewUser
        ]
        return dict.compactMapValues({ $0 })
    }
    
}
