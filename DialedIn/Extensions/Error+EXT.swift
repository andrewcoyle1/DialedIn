//
//  Error+EXT.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 20/07/2025.
//

import Foundation

extension Error {
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
