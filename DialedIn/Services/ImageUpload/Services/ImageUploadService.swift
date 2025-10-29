//
//  ImageUploadService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

protocol ImageUploadService: Sendable {
    func uploadImage(image: PlatformImage, path: String) async throws -> URL
    func deleteImage(path: String) async throws
}
