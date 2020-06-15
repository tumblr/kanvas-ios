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

    /// Returns a new video url
    static func videoURL() throws -> URL {
        return try unique(filename: URLConstants.baseURL, fileExtension: URLConstants.mp4, unique: true, removeExisting: false)
    }
    
    /// Returns a new image url
    static func imageURL() throws -> URL {
        return try unique(filename: URLConstants.baseURL, fileExtension: URLConstants.jpg, unique: true, removeExisting: false)
    }

    enum URLError: Error {
        case noDocumentsURL
        case failed
    }
    
    /// Returns a url of the given extension
    static func unique(filename: String, fileExtension: String, unique: Bool, removeExisting: Bool) throws -> URL {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw URLError.noDocumentsURL
        }

        if !FileManager.default.fileExists(atPath: documentsURL.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
        }

        var fileURL: URL?
        while true {
            let uniqueFilename = unique ?
                "\(filename)-\(UUID().uuidString).\(fileExtension)" :
                "\(filename).\(fileExtension)"
            fileURL = documentsURL.appendingPathComponent(uniqueFilename, isDirectory: false)
            guard let newFileURL = fileURL else {
                break
            }
            guard FileManager.default.fileExists(atPath: newFileURL.path) else {
                break
            }
            guard !removeExisting else {
                try FileManager.default.removeItem(at: newFileURL)
                break
            }
        }

        guard let newFileURL = fileURL else {
            throw URLError.failed
        }

        return newFileURL
    }
    
}
