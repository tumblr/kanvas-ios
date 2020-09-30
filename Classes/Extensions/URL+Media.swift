//
// Created by Tony Cheng on 7/3/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

import AVFoundation
import Foundation

/// Constants for url extensions and paths
private struct URLConstants {
    static let jpg = "jpg"
    static let mp4 = "mp4"
    static let baseURL: String = "kanvas"
}

/// This is an extension to help create new URLs for videos and images
extension URL {

    /// Makes a new video URL
    static func videoURL() throws -> URL {
        return try URL(filename: URLConstants.baseURL, fileExtension: URLConstants.mp4, unique: true, removeExisting: false)
    }
    
    /// Makes a new image URL
    static func imageURL() throws -> URL {
        return try URL(filename: URLConstants.baseURL, fileExtension: URLConstants.jpg, unique: true, removeExisting: false)
    }

    enum URLError: Error {
        case noDocumentsURL
    }
    
    /// URL Initializer for Kanvas's files
    /// - Parameters:
    ///     - filename: the filename
    ///     - fileExtension: the file extension (without the `.`)
    ///     - unique: whether or not to add "-\(uuid)" to the filename
    ///     - removeExisting: if the file URL already exists, remove it
    init(filename: String, fileExtension: String, unique: Bool, removeExisting: Bool) throws {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw URLError.noDocumentsURL
        }

        if !FileManager.default.fileExists(atPath: documentsURL.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
        }

        let fullFilename = unique ?
            "\(filename)-\(UUID().uuidString).\(fileExtension)" :
            "\(filename).\(fileExtension)"
        let fileURL = documentsURL.appendingPathComponent(fullFilename, isDirectory: false)
        if removeExisting && FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        self = fileURL
    }
}
