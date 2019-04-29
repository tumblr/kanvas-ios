//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

public class MediaMetadata {

    class func createAVMetadataItems(from mediaInfo: MediaInfo) -> [AVMetadataItem] {
        let metadataItem = AVMutableMetadataItem()
        // Using quickTimeMetadataTitle since that seems to be the
        // ONLY metadata key that will actually be persisted ¯\_(ツ)_/¯
        metadataItem.identifier = AVMetadataIdentifier.quickTimeMetadataTitle
        metadataItem.key = AVMetadataKey.quickTimeMetadataKeyTitle.rawValue as NSCopying & NSObjectProtocol
        metadataItem.keySpace = .quickTimeMetadata
        metadataItem.value = mediaInfo.rawValue as NSCopying & NSObjectProtocol
        return [metadataItem]
    }

    public class func readMediaInfo(fromVideo url: NSURL) -> MediaInfo? {
        let asset = AVAsset(url: url as URL)
        let metadataItems = asset.metadata
        guard let metadataItem = metadataItems.first else {
            return nil
        }
        guard let value = metadataItem.stringValue else {
            return nil
        }
        return MediaInfo(rawValue: value)
    }

    public class func write(mediaInfo: MediaInfo, toImage url: NSURL) {
        let imageRefMaybe = CGImageSourceCreateWithURL(url, nil)
        guard let imageRef = imageRefMaybe else {
            assertionFailure()
            return
        }
        let typeMaybe = CGImageSourceGetType(imageRef)
        guard let type = typeMaybe else {
            assertionFailure()
            return
        }
        guard let destination = CGImageDestinationCreateWithURL(url, type, 1, nil) else {
            assertionFailure()
            return
        }
        let properties = [
            kCGImagePropertyExifDictionary: [
                kCGImagePropertyExifUserComment: mediaInfo.rawValue
            ]
        ]
        CGImageDestinationAddImageFromSource(destination, imageRef, 0, properties as CFDictionary)
        let success = CGImageDestinationFinalize(destination)
        if !success {
            assertionFailure()
            return
        }
    }

    public class func readMediaInfo(fromImage url: URL) throws -> MediaInfo? {
        let data = try Data(contentsOf: url)
        guard let source: CGImageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] ?? [:]
        let exif = metadata[kCGImagePropertyExifDictionary as String] as? [String: AnyObject] ?? [:]
        guard let value = exif[kCGImagePropertyExifUserComment as String] as? String else {
            return nil
        }
        return MediaInfo(rawValue: value)
    }

}
