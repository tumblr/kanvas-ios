//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Kanvas
import Foundation
import UIKit

#if !SWIFT_PACKAGE
extension URLSessionTask: KanvasCancelable {
}
#endif

class ImageLoader: KanvasStickerLoader {
    func loadSticker(at imageURL: URL, imageView: UIImageView?, completion: @escaping (UIImage?, Error?) -> Void) -> KanvasCancelable {
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let data = data {
                imageView?.image = UIImage(data: data)
            }
        }
        return task
    }
}

final class StickerProviderStub: StickerProvider {
    
    func loader() -> KanvasStickerLoader? {
        return ImageLoader()
    }
    
    func getStickerTypes() {
        
    }
    
    func setDelegate(delegate: StickerProviderDelegate) {
        
    }
}
