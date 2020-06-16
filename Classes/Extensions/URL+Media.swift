//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
