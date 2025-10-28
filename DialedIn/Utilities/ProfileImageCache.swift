//
//  ProfileImageCache.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation
import SwiftUI

class ProfileImageCache {
    static let shared = ProfileImageCache()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Create cache directory in app's documents directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("ProfileImages", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public API
    
    /// Get cached image for user
    func getCachedImage(userId: String) -> PlatformImage? {
        let fileURL = imageURL(for: userId)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        #if canImport(UIKit)
        return UIImage(data: data)
        #elseif canImport(AppKit)
        return NSImage(data: data)
        #endif
    }
    
    /// Cache image for user
    func cacheImage(_ image: PlatformImage, userId: String) throws {
        let fileURL = imageURL(for: userId)
        
        #if canImport(UIKit)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw CacheError.imageConversionFailed
        }
        #elseif canImport(AppKit)
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let data = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            throw CacheError.imageConversionFailed
        }
        #endif
        
        try data.write(to: fileURL)
    }
    
    /// Download and cache image from URL
    func downloadAndCache(from urlString: String, userId: String) async throws -> PlatformImage {
        guard let url = URL(string: urlString) else {
            throw CacheError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else {
            throw CacheError.imageConversionFailed
        }
        #elseif canImport(AppKit)
        guard let image = NSImage(data: data) else {
            throw CacheError.imageConversionFailed
        }
        #endif
        
        // Cache the downloaded image
        try cacheImage(image, userId: userId)
        
        return image
    }
    
    /// Remove cached image for user
    func removeCachedImage(userId: String) {
        let fileURL = imageURL(for: userId)
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Clear all cached images
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Private Helpers
    
    private func imageURL(for userId: String) -> URL {
        // Use a safe filename by hashing the userId
        let filename = "\(userId.hashValue).jpg"
        return cacheDirectory.appendingPathComponent(filename)
    }
    
    enum CacheError: Error, LocalizedError {
        case invalidURL
        case imageConversionFailed
        case downloadFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid image URL"
            case .imageConversionFailed:
                return "Failed to convert image"
            case .downloadFailed:
                return "Failed to download image"
            }
        }
    }
}
