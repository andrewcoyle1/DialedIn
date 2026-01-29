//
//  UserWeightServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

protocol UserWeightServices {
    var remote: RemoteUserWeightService { get }
    var local: LocalUserWeightService { get }
}
