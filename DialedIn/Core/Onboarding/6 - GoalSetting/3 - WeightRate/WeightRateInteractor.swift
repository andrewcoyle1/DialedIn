//
//  WeightRateInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WeightRateInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: WeightRateInteractor { }
