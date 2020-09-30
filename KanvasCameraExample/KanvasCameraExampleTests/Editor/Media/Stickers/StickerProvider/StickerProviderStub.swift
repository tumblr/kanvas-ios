//
//  StickerProviderStub.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 24/11/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

import KanvasCamera
import Foundation

extension URLSessionTask: KanvasCancelable {
}

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
