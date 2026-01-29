//
//  ProductionPushServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionPushServices: PushServices {
    let local: LocalPushService = ProductionLocalPushService()
}
