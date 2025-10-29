//
//  ProductionUserWeightServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionUserWeightServices: UserWeightServices {
    let remote: RemoteUserWeightService = ProductionRemoteUserWeightService()
    let local: LocalUserWeightService = ProductionLocalUserWeightService()
}
