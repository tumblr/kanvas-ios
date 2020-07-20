//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public protocol Cancelable {
    /// Cancels the running operation.
    func cancel()
}

public protocol StickerLoader {
    func loadImage(at imageURL: URL,
                   OAuth: Bool,
                   imageView: UIImageView?,
                   displayImageImmediately: Bool,
                   preloadAllFrames: Bool,
                   completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) -> Cancelable
}
