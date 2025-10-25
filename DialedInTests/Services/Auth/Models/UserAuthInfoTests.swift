//
//  UserAuthInfoTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Testing
import Foundation

struct UserAuthInfoTests {

    // MARK: - Initialization Tests
    
    @Test("Test Basic Initialisation")
    func testBasicInitialization() {
        let randomUid = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo.uid == randomUid)
        #expect(authInfo.email == randomEmail)
        #expect(authInfo.isAnonymous == false)
        #expect(authInfo.isNewUser == randomIsNewUser)
    }
    
    @Test("Test Initialization With All Properties")
    func testInitializationWithAllProperties() {
        let testData = createUserAuthInfoTestData()
        let authInfo = createUserAuthInfoWithAllProperties(data: testData)
        verifyUserAuthInfoProperties(authInfo: authInfo, data: testData)
    }
    
    private func createUserAuthInfoTestData() -> UserAuthInfoTestData {
        return UserAuthInfoTestData(
            uid: String.random,
            email: "\(String.random)@example.com",
            isAnonymous: Bool.random,
            creationDate: Date.random,
            lastSignInDate: Date.random,
            isNewUser: Bool.random
        )
    }
    
    private struct UserAuthInfoTestData {
        let uid: String
        let email: String?
        let isAnonymous: Bool
        let creationDate: Date?
        let lastSignInDate: Date?
        let isNewUser: Bool
    }
    
    private func createUserAuthInfoWithAllProperties(data: UserAuthInfoTestData) -> UserAuthInfo {
        return UserAuthInfo(
            uid: data.uid,
            email: data.email,
            isAnonymous: data.isAnonymous,
            creationDate: data.creationDate,
            lastSignInDate: data.lastSignInDate,
            isNewUser: data.isNewUser
        )
    }
    
    private func verifyUserAuthInfoProperties(authInfo: UserAuthInfo, data: UserAuthInfoTestData) {
        #expect(authInfo.uid == data.uid)
        #expect(authInfo.email == data.email)
        #expect(authInfo.isAnonymous == data.isAnonymous)
        #expect(authInfo.creationDate == data.creationDate)
        #expect(authInfo.lastSignInDate == data.lastSignInDate)
        #expect(authInfo.isNewUser == data.isNewUser)
    }
    
    @Test("Test Initialization With Nil Values")
    func testInitializationWithNilValues() {
        let randomUid = String.random
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            email: nil,
            isAnonymous: false,
            creationDate: nil,
            lastSignInDate: nil,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo.uid == randomUid)
        #expect(authInfo.email == nil)
        #expect(authInfo.isAnonymous == false)
        #expect(authInfo.creationDate == nil)
        #expect(authInfo.lastSignInDate == nil)
        #expect(authInfo.isNewUser == randomIsNewUser)
    }
    
    @Test("Test Initialization With Default Parameters")
    func testInitializationWithDefaultParameters() {
        let randomUid = String.random
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo.uid == randomUid)
        #expect(authInfo.email == nil)
        #expect(authInfo.isAnonymous == false)
        #expect(authInfo.creationDate == nil)
        #expect(authInfo.lastSignInDate == nil)
        #expect(authInfo.isNewUser == randomIsNewUser)
    }
    
    @Test("Test Initialization With Anonymous User")
    func testInitializationWithAnonymousUser() {
        let randomUid = String.random
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            isAnonymous: true,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo.uid == randomUid)
        #expect(authInfo.isAnonymous == true)
        #expect(authInfo.isNewUser == randomIsNewUser)
    }
    
    // MARK: - Equatable Tests
    
    @Test("Test Equality With Same Properties")
    func testEqualityWithSameProperties() {
        let randomUid = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomCreationDate = Date.random
        let randomLastSignInDate = Date.random
        let randomIsNewUser = Bool.random
        
        let authInfo1 = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isAnonymous: false,
            creationDate: randomCreationDate,
            lastSignInDate: randomLastSignInDate,
            isNewUser: randomIsNewUser
        )
        
        let authInfo2 = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isAnonymous: false,
            creationDate: randomCreationDate,
            lastSignInDate: randomLastSignInDate,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo1 == authInfo2)
    }
    
    @Test("Test Inequality With Different UID")
    func testInequalityWithDifferentUID() {
        let randomEmail = "\(String.random)@example.com"
        let randomIsNewUser = Bool.random
        
        let authInfo1 = UserAuthInfo(
            uid: String.random,
            email: randomEmail,
            isNewUser: randomIsNewUser
        )
        
        let authInfo2 = UserAuthInfo(
            uid: String.random,
            email: randomEmail,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo1 != authInfo2)
    }
    
    @Test("Test Inequality With Different Email")
    func testInequalityWithDifferentEmail() {
        let randomUid = String.random
        let randomIsNewUser = Bool.random
        
        let authInfo1 = UserAuthInfo(
            uid: randomUid,
            email: "\(String.random)@example.com",
            isNewUser: randomIsNewUser
        )
        
        let authInfo2 = UserAuthInfo(
            uid: randomUid,
            email: "\(String.random)@example.com",
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo1 != authInfo2)
    }
    
    @Test("Test Inequality With Different IsAnonymous")
    func testInequalityWithDifferentIsAnonymous() {
        let randomUid = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsNewUser = Bool.random
        
        let authInfo1 = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isAnonymous: false,
            isNewUser: randomIsNewUser
        )
        
        let authInfo2 = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isAnonymous: true,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo1 != authInfo2)
    }
    
    @Test("Test Inequality With Different IsNewUser")
    func testInequalityWithDifferentIsNewUser() {
        let randomUid = String.random
        let randomEmail = "\(String.random)@example.com"
        
        let authInfo1 = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isNewUser: true
        )
        
        let authInfo2 = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isNewUser: false
        )
        
        #expect(authInfo1 != authInfo2)
    }
    
    @Test("Test Inequality With Different Creation Date")
    func testInequalityWithDifferentCreationDate() {
        let randomUid = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsNewUser = Bool.random
        
        let authInfo1 = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            creationDate: Date.random,
            isNewUser: randomIsNewUser
        )
        
        let authInfo2 = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            creationDate: Date.random,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo1 != authInfo2)
    }
    
    // MARK: - Codable Tests
    
    @Test("Test Encoding And Decoding")
    func testEncodingAndDecoding() throws {
        let randomUid = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomCreationDate = Date.random
        let randomLastSignInDate = Date.random
        let randomIsNewUser = Bool.random
        
        let originalAuthInfo = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isAnonymous: false,
            creationDate: randomCreationDate,
            lastSignInDate: randomLastSignInDate,
            isNewUser: randomIsNewUser
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let encodedData = try encoder.encode(originalAuthInfo)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let decodedAuthInfo = try decoder.decode(UserAuthInfo.self, from: encodedData)
        
        // With millisecondsSince1970, dates preserve sub-second precision
        #expect(decodedAuthInfo == originalAuthInfo)
    }
    
    @Test("Test Encoding Nil Values")
    func testEncodingNilValues() throws {
        let randomUid = String.random
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            email: nil,
            isAnonymous: false,
            creationDate: nil,
            lastSignInDate: nil,
            isNewUser: randomIsNewUser
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let encodedData = try encoder.encode(authInfo)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let decodedAuthInfo = try decoder.decode(UserAuthInfo.self, from: encodedData)
        
        #expect(decodedAuthInfo.uid == randomUid)
        #expect(decodedAuthInfo.email == nil)
        #expect(decodedAuthInfo.creationDate == nil)
        #expect(decodedAuthInfo.lastSignInDate == nil)
        #expect(decodedAuthInfo.isNewUser == randomIsNewUser)
    }
    
    @Test("Test Coding Keys Mapping")
    func testCodingKeysMapping() throws {
        let randomUid = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isAnonymous: true,
            isNewUser: randomIsNewUser
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let encodedData = try encoder.encode(authInfo)
        
        let json = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any]
        
        #expect(json?["uid"] as? String == randomUid)
        #expect(json?["email"] as? String == randomEmail)
        #expect(json?["is_anonymous"] as? Bool == true)
        #expect(json?["is_new_user"] as? Bool == randomIsNewUser)
    }
    
    // MARK: - Event Parameters Tests
    
    @Test("Test Event Parameters")
    func testEventParameters() {
        let randomUid = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomCreationDate = Date.random
        let randomLastSignInDate = Date.random
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isAnonymous: false,
            creationDate: randomCreationDate,
            lastSignInDate: randomLastSignInDate,
            isNewUser: randomIsNewUser
        )
        
        let eventParams = authInfo.eventParameters
        
        #expect(eventParams["uauth_uid"] as? String == randomUid)
        #expect(eventParams["uauth_email"] as? String == randomEmail)
        #expect(eventParams["uauth_is_anonymous"] as? Bool == false)
        #expect(eventParams["uauth_is_new_user"] as? Bool == randomIsNewUser)
    }
    
    @Test("Test Event Parameters Filters Nil Values")
    func testEventParametersFiltersNilValues() {
        let randomUid = String.random
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            email: nil,
            isAnonymous: false,
            creationDate: nil,
            lastSignInDate: nil,
            isNewUser: randomIsNewUser
        )
        
        let eventParams = authInfo.eventParameters
        
        #expect(eventParams["uauth_uid"] as? String == randomUid)
        #expect(eventParams["uauth_email"] == nil)
        #expect(eventParams["uauth_is_anonymous"] as? Bool == false)
        #expect(eventParams["uauth_is_new_user"] as? Bool == randomIsNewUser)
    }
    
    // MARK: - Mock Tests
    
    @Test("Test Mock Property With Default Anonymous")
    func testMockPropertyWithDefaultAnonymous() {
        let mock = UserAuthInfo.mock()
        
        #expect(mock.uid == "mock_user_123")
        #expect(mock.email == "hello@swiftful-thinking.com")
        #expect(mock.isAnonymous == false)
        #expect(mock.isNewUser == true)
    }
    
    @Test("Test Mock Property With Anonymous True")
    func testMockPropertyWithAnonymousTrue() {
        let mock = UserAuthInfo.mock(isAnonymous: true)
        
        #expect(mock.uid == "mock_user_123")
        #expect(mock.email == "hello@swiftful-thinking.com")
        #expect(mock.isAnonymous == true)
        #expect(mock.isNewUser == true)
    }
    
    @Test("Test Mock Property With Anonymous False")
    func testMockPropertyWithAnonymousFalse() {
        let mock = UserAuthInfo.mock(isAnonymous: false)
        
        #expect(mock.uid == "mock_user_123")
        #expect(mock.email == "hello@swiftful-thinking.com")
        #expect(mock.isAnonymous == false)
        #expect(mock.isNewUser == true)
    }
    
    @Test("Test Mock Has Creation Date")
    func testMockHasCreationDate() {
        let mock = UserAuthInfo.mock()
        
        #expect(mock.creationDate != nil)
    }
    
    @Test("Test Mock Has Last Sign In Date")
    func testMockHasLastSignInDate() {
        let mock = UserAuthInfo.mock()
        
        #expect(mock.lastSignInDate != nil)
    }
    
    // MARK: - Sendable Tests
    
    @Test("Test UserAuthInfo Is Sendable")
    func testUserAuthInfoIsSendable() {
        let randomUid = String.random
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            isNewUser: randomIsNewUser
        )
        
        // UserAuthInfo conforms to Sendable, so it can be passed across concurrency boundaries
        #expect(type(of: authInfo) == UserAuthInfo.self)
    }
    
    // MARK: - Edge Cases
    
    @Test("Test Email With Special Characters")
    func testEmailWithSpecialCharacters() {
        let randomUid = String.random
        let specialEmail = "test+user@example.co.uk"
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            email: specialEmail,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo.email == specialEmail)
    }
    
    @Test("Test Empty String UID")
    func testEmptyStringUID() {
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: "",
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo.uid == "")
    }
    
    @Test("Test Very Long UID")
    func testVeryLongUID() {
        let longUid = String(repeating: "a", count: 1000)
        let randomIsNewUser = Bool.random
        
        let authInfo = UserAuthInfo(
            uid: longUid,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo.uid == longUid)
    }
    
    @Test("Test Equality With Nil Email")
    func testEqualityWithNilEmail() {
        let randomUid = String.random
        let randomIsNewUser = Bool.random
        
        let authInfo1 = UserAuthInfo(
            uid: randomUid,
            email: nil,
            isNewUser: randomIsNewUser
        )
        
        let authInfo2 = UserAuthInfo(
            uid: randomUid,
            email: nil,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo1 == authInfo2)
    }
    
    @Test("Test Inequality With One Nil Email")
    func testInequalityWithOneNilEmail() {
        let randomUid = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsNewUser = Bool.random
        
        let authInfo1 = UserAuthInfo(
            uid: randomUid,
            email: nil,
            isNewUser: randomIsNewUser
        )
        
        let authInfo2 = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isNewUser: randomIsNewUser
        )
        
        #expect(authInfo1 != authInfo2)
    }
}
