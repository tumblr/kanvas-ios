//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// The class containing an image or video and associated data (an encoded representation of the edits).
class Archive: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true

    let image: UIImage?
    let video: URL?
    let data: Data?

    init(image: UIImage, data: Data?) {
        self.image = image
        self.data = data
        self.video = nil
    }

    init(video: URL, data: Data?) {
        self.video = video
        self.data = data
        self.image = nil
    }

    private enum CodingKeys: String {
        case image
        case video
        case data
    }

    func encode(with coder: NSCoder) {
        coder.encode(image, forKey: CodingKeys.image.rawValue)
        coder.encode(video?.absoluteString, forKey: CodingKeys.video.rawValue)
        coder.encode(data?.base64EncodedString(), forKey: CodingKeys.data.rawValue)
    }

    required init?(coder: NSCoder) {
        image = coder.decodeObject(of: UIImage.self, forKey: CodingKeys.image.rawValue)
        if let urlString = coder.decodeObject(of: NSString.self, forKey: CodingKeys.video.rawValue) as String? {
            video = URL(string: urlString)
        } else {
            video = nil
        }
        if let dataString = coder.decodeObject(of: NSString.self, forKey: CodingKeys.data.rawValue) as String? {
            data = Data(base64Encoded: dataString)
        } else {
            data = nil
        }
    }
}
