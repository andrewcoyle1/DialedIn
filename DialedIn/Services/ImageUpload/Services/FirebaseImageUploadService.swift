//
//  FirebaseImageUploadService.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/16/24.
//
@preconcurrency import FirebaseStorage
import SwiftUI

                   protocol ImageUploadService {
    func uploadImage(image: PlatformImage, path: String) async throws -> URL
}

struct FirebaseImageUploadService {
    
    func uploadImage(image: PlatformImage, path: String) async throws -> URL {
        let data = try await prepareJPEGData(image: image)
        _ = try await saveImage(data: data, path: path)
        return try await imageReference(path: path).downloadURL()
    }
    
    private func imageReference(path: String) -> StorageReference {
        let name = "\(path).jpg"
        return Storage.storage().reference(withPath: name)
    }
    
    private func saveImage(data: Data, path: String) async throws -> URL {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        let returnedMeta = try await imageReference(path: path).putDataAsync(data, metadata: meta)
        guard let returnedPath = returnedMeta.path, let url = URL(string: returnedPath) else {
            throw URLError(.badServerResponse)
        }
        return url
    }
    
    private func prepareJPEGData(image: PlatformImage, maxDimension: CGFloat = 1280, quality: CGFloat = 0.7) async throws -> Data {
        #if canImport(UIKit)
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached(priority: .userInitiated) {
                let size = image.size
                let longest = max(size.width, size.height)
                let scale = min(1, maxDimension / max(longest, 1))
                let targetSize = CGSize(width: max(size.width * scale, 1), height: max(size.height * scale, 1))
                UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0)
                image.draw(in: CGRect(origin: .zero, size: targetSize))
                let resized = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                guard let jpeg = resized?.jpegData(compressionQuality: quality) else {
                    continuation.resume(throwing: URLError(.dataNotAllowed))
                    return
                }
                continuation.resume(returning: jpeg)
            }
        }
        #else
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached(priority: .userInitiated) {
                guard let tiffData = image.tiffRepresentation,
                      let bitmap = NSBitmapImageRep(data: tiffData) else {
                    continuation.resume(throwing: URLError(.dataNotAllowed))
                    return
                }
                // Resize if needed
                let size = NSSize(width: image.size.width, height: image.size.height)
                let longest = max(size.width, size.height)
                let scale = min(1, maxDimension / max(longest, 1))
                let targetSize = NSSize(width: max(size.width * scale, 1), height: max(size.height * scale, 1))
                let resizedImage = NSImage(size: targetSize)
                resizedImage.lockFocus()
                image.draw(in: NSRect(origin: .zero, size: targetSize))
                resizedImage.unlockFocus()
                guard let resizedTiff = resizedImage.tiffRepresentation,
                      let resizedBitmap = NSBitmapImageRep(data: resizedTiff),
                      let jpeg = resizedBitmap.representation(using: .jpeg, properties: [.compressionFactor: quality]) else {
                    continuation.resume(throwing: URLError(.dataNotAllowed))
                    return
                }
                continuation.resume(returning: jpeg)
            }
        }
        #endif
    }
}
