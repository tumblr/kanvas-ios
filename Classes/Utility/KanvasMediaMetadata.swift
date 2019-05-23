//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

/// Read and write metadata to media files.
public class KanvasMediaMetadata {

    class func createAVMetadataItems(from mediaInfo: KanvasMediaInfo) -> [AVMetadataItem] {
        guard let JSONData = try? JSONEncoder().encode(mediaInfo) else {
            assertionFailure("Failed to encode JSON media info")
            return []
        }
        guard let JSON = String(data: JSONData, encoding: .utf8) else {
            assertionFailure("Failed to decode data as utf-8 string")
            return []
        }
        let metadataItem = AVMutableMetadataItem()
        // Using quickTimeMetadataTitle since that seems to be the
        // ONLY metadata key that will actually be persisted ¯\_(ツ)_/¯
        metadataItem.identifier = AVMetadataIdentifier.quickTimeMetadataTitle
        metadataItem.key = AVMetadataKey.quickTimeMetadataKeyTitle.rawValue as NSCopying & NSObjectProtocol
        metadataItem.keySpace = .quickTimeMetadata
        metadataItem.value = JSON as NSCopying & NSObjectProtocol
        return [metadataItem]
    }

    /// Reads media info from a video url
    /// - Parameter fromVideo: the video URL to read metadata from
    /// - Returns: KanvasMediaInfo
    public class func readMediaInfo(fromVideo url: NSURL) -> KanvasMediaInfo? {
        let asset = AVAsset(url: url as URL)
        let metadataItems = asset.metadata
        guard let metadataItem = metadataItems.first else {
            return nil
        }
        guard let JSONString = metadataItem.stringValue else {
            return nil
        }
        guard let JSONData = JSONString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(KanvasMediaInfo.self, from: JSONData)
    }

    /// Writes media info to an image URL
    /// - Parameter mediaInfo: MediaInfo to write
    /// - Parameter toImage: the image URL to write metadata to
    public class func write(mediaInfo: KanvasMediaInfo, toImage url: NSURL) {
        guard let imageRef = CGImageSourceCreateWithURL(url, nil) else {
            assertionFailure()
            return
        }
        guard let type = CGImageSourceGetType(imageRef) else {
            assertionFailure()
            return
        }
        guard let destination = CGImageDestinationCreateWithURL(url, type, 1, nil) else {
            assertionFailure()
            return
        }
        guard let mediaInfoData = try? JSONEncoder().encode(mediaInfo) else {
            assertionFailure()
            return
        }
        guard let mediaInfoJSON = String(data: mediaInfoData, encoding: .utf8) else {
            assertionFailure()
            return
        }
        let properties = [
            kCGImagePropertyExifDictionary: [
                kCGImagePropertyExifUserComment: mediaInfoJSON
            ]
        ]
        CGImageDestinationAddImageFromSource(destination, imageRef, 0, properties as CFDictionary)
        let success = CGImageDestinationFinalize(destination)
        guard success else {
            assertionFailure()
            return
        }
    }

    /// Reads media info from an image URL
    /// - Parameter fromImage: image URL to read metadata from
    /// - Returns: KanvasMediaInfo?
    /// - Throws: when data cannot be read from url
    public class func readMediaInfo(fromImage url: URL) throws -> KanvasMediaInfo? {
        let data = try Data(contentsOf: url)
        guard let source: CGImageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] ?? [:]
        let exif = metadata[kCGImagePropertyExifDictionary as String] as? [String: AnyObject] ?? [:]
        guard let value = exif[kCGImagePropertyExifUserComment as String] as? String else {
            return nil
        }
        guard let jsonData = value.data(using: .utf8) else {
            return nil
        }
        return try JSONDecoder().decode(KanvasMediaInfo.self, from: jsonData)
    }

}
