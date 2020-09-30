//
//  AVAsset+Utils.swift
//  Utils
//
//  Created by Taichi Matsumoto on 2/10/20.
//

import AVFoundation

public extension AVAsset {
    var videoScreenSize: CGSize? {
        if let track = tracks(withMediaType: .video).first {
            let size = __CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform)
            return CGSize(width: abs(size.width), height: abs(size.height))
        }
        return nil
    }
}
