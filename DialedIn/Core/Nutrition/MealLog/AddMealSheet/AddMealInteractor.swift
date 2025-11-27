//
//  AddMealInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol AddMealInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: AddMealInteractor { }
