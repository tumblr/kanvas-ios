//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import KanvasCamera
import Foundation

extension URLSessionTask: Cancelable {
}

class ImageLoader: StickerLoader {
    func loadImage(at imageURL: URL,
                   OAuth: Bool,
                   imageView: UIImageView?,
                   displayImageImmediately: Bool,
                   preloadAllFrames: Bool,
                   completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) -> Cancelable {
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let data = data {
                imageView?.image = UIImage(data: data)
            }
        }
        return task
    }
}

final class StickerProviderStub: StickerProvider {
    func loader() -> StickerLoader {
        return ImageLoader()
    }
    
    func getStickerTypes() {
        
    }
    
    func setDelegate(delegate: StickerProviderDelegate) {
        
    }
}
