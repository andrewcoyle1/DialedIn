//
//  TemplateModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import Foundation

/// Protocol that all template models must conform to
/// Provides a common interface for working with different template types
protocol TemplateModel: Identifiable, Codable, Hashable {
    var id: String { get }
    var name: String { get }
    var description: String? { get }
    var imageURL: String? { get }
}
