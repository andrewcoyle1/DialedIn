//
//  UserServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/15/24.
//

protocol UserServices {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistence { get }
}
