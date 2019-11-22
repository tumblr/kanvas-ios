//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// An extension for loading an image asynchronously by providing an URL or string.
extension UIImageView {
    
    func load(from url: URL, completion: ((URL, UIImage) -> Void)? = nil) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            completion?(url, image)
            DispatchQueue.main.async() {
                self.image = image
            }
        }
        task.resume()
        return task
    }
    
    func load(from link: String, completion: ((URL, UIImage) -> Void)? = nil) -> URLSessionTask? {
        guard let url = URL(string: link) else { return nil }
        return load(from: url, completion: completion)
    }
}
