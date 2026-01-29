//
//  ImageUploadManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import Foundation

@Observable
class ImageUploadManager {
    private let service: ImageUploadService
    
    init(service: ImageUploadService) {
        self.service = service
    }
    
    func uploadImage(image: PlatformImage, path: String) async throws -> URL {
        try await service.uploadImage(image: image, path: path)
    }
    
    func deleteImage(path: String) async throws {
        try await service.deleteImage(path: path)
    }
}
