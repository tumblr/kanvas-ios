//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

/// Constants for url extensions and paths
private struct URLConstants {
    static let jpg = "jpg"
    static let mp4 = "mp4"
    static let BaseURL: String = "camera-asset-%@.%@"
}

/// This is an extension to help create new URLs for videos and images
extension NSURL {
    
    /// Returns a new video url
    class func createNewVideoURL() -> URL? {
        return createURLWithExtension(URLConstants.mp4)
    }
    
    /// Returns a new image url
    class func createNewImageURL() -> URL? {
        return createURLWithExtension(URLConstants.jpg)
    }
    
    /// Returns a url of the given extension
    private class func createURLWithExtension(_ ext: String) -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            NSLog("documents directory should exist")
            return nil
        }
        var requiresNewFilePath = true
        var fileURL: URL = documentsURL.appendingPathComponent(String(format: URLConstants.BaseURL, NSUUID().uuidString, ext))
        
        while requiresNewFilePath {
            if FileManager.default.fileExists(atPath: fileURL.path) != true {
                requiresNewFilePath = false
                break
            }
            fileURL = documentsURL.appendingPathComponent(String(format: URLConstants.BaseURL, NSUUID().uuidString, ext))
        }
        return fileURL
    }
    
}
