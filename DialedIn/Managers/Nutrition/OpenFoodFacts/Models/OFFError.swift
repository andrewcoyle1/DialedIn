//
//  OFFError.swift
//  DialedIn
//
//  Created by Andrew Coyle on 12/03/2026.
//

import Foundation

enum OFFError: LocalizedError {
    case productNotFound
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Product not found. Try a different barcode."
        case .invalidResponse: return "Invalid response from Open Food Facts."
        }
    }
}
