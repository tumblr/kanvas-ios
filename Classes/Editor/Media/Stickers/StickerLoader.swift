//
//  StickerLoader.swift
//  KanvasCamera
//
//  Created by Brandon Titus on 6/18/20.
//

import Foundation

public protocol KanvasCancelable {
    /// Cancels the running operation.
    func cancel()
}

public protocol KanvasStickerLoader {

    func loadSticker(at imageURL: URL, imageView: UIImageView?, completion: @escaping (UIImage?, Error?) -> Void) -> KanvasCancelable

}
