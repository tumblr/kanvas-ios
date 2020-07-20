//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

public typealias MediaInfo = MediaInfoSimple

public struct MediaInfoSimple {

    public enum Source {
        case kanvas_camera
        case media_library
    }

    public let source: Source

    public init(source: Source) {
        self.source = source
    }
}

extension MediaInfoSimple: Codable {
    private enum CodingKeys: String, CodingKey {
        case source
    }
}

extension MediaInfoSimple.Source: Codable {
    private enum CodingKeys: String, CodingKey {
        case kanvas_camera = "camera"
        case media_library = "library"
    }

    enum LegacyValue: String {
        case kanvas
    }

    enum CodingError: Error {
        case decoding(String)
    }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case CodingKeys.kanvas_camera.rawValue:
            self = .kanvas_camera
        case CodingKeys.media_library.rawValue:
            self = .media_library
        default:
            throw CodingError.decoding("Invalid Source: \(value)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .kanvas_camera:
            try container.encode(CodingKeys.kanvas_camera.rawValue)
        case .media_library:
            try container.encode(CodingKeys.media_library.rawValue)
        }
    }

    public func stringValue() -> String {
        switch self {
        case .kanvas_camera:
            return CodingKeys.kanvas_camera.rawValue
        case .media_library:
            return CodingKeys.media_library.rawValue
        }
    }
}

/// Read and write metadata from/to images.
extension MediaInfo {

    /// Reads media info from an image URL
    public init?(fromImage url: URL) {
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(fromImageData: data)
    }

    /// Reads media info from image data
    /// - Parameter fromImageData: The Data representation of an image
    /// - Throws: when data cannot be read from url
    public init?(fromImageData data: Data) {
        guard let source: CGImageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] ?? [:]
        let exif = metadata[kCGImagePropertyExifDictionary as String] as? [String: AnyObject] ?? [:]
        guard let value = exif[kCGImagePropertyExifUserComment as String] as? String else {
            return nil
        }
        if value == Source.LegacyValue.kanvas.rawValue {
            self.init(source: .kanvas_camera)
        }
        else {
            if let jsonData = value.data(using: .utf8) {
                if let mediaInfo = try? JSONDecoder().decode(MediaInfoSimple.self, from: jsonData) {
                    self = mediaInfo
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
    }

    /// Writes media info to an image URL
    /// - Parameter toImage: the image URL to write metadata to
    public func write(toImage url: URL) {
        guard let imageRef = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            assertionFailure()
            return
        }
        guard let type = CGImageSourceGetType(imageRef) else {
            assertionFailure()
            return
        }
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, type, 1, nil) else {
            assertionFailure()
            return
        }
        guard let mediaInfoData = try? JSONEncoder().encode(self) else {
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
}

/// Read and write metadata from/to videos.
extension MediaInfo {

    /// Reads media info from a video url
    public init?(fromVideoURL url: URL) {
        let asset = AVAsset(url: url)
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
        if let mediaInfo = try? JSONDecoder().decode(MediaInfoSimple.self, from: JSONData) {
            self = mediaInfo
        }
        else {
            return nil
        }
    }

    public func createAVMetadataItems() -> [AVMetadataItem] {
        guard let JSONData = try? JSONEncoder().encode(self) else {
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
}
