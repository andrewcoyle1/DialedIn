//
//  SearchInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/01/2026.
//

protocol SearchInteractor {
    var userImageUrl: String? { get }
}

extension CoreInteractor: SearchInteractor { }
