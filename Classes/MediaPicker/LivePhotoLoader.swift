//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import Photos

public class LivePhotoLoader {

    let asset: PHAsset

    var pairedVideoURL: URL?

    var isLivePhoto: Bool {
        asset.mediaSubtypes.contains(.photoLive)
    }

    public init(asset: PHAsset) {
        self.asset = asset
    }

    public func pairedVideo(completion: @escaping (URL?) -> Void) {
        func mainCompletion(url: URL?) {
            DispatchQueue.main.async {
                completion(url)
            }
        }
        guard pairedVideoURL == nil else {
            mainCompletion(url: pairedVideoURL)
            return
        }
        guard isLivePhoto else {
            mainCompletion(url: nil)
            return
        }
        let options = PHLivePhotoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestLivePhoto(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { (livePhoto: PHLivePhoto?, info: [AnyHashable: Any]?) in
            guard let livePhoto = livePhoto else {
                print("Photo Library Asset is not a Live Photo")
                mainCompletion(url: nil)
                return
            }
            let assetResources = PHAssetResource.assetResources(for: livePhoto)
            for resource in assetResources {
                if resource.type == PHAssetResourceType.pairedVideo {
                    guard let url = try? URL.videoURL() else {
                        print("Failed to create video URL")
                        mainCompletion(url: nil)
                        return
                    }
                    let options = PHAssetResourceRequestOptions()
                    options.isNetworkAccessAllowed = true
                    PHAssetResourceManager.default().writeData(for: resource, toFile: url, options: nil) { error in
                        guard error == nil else {
                            print("Error writing Live Photo video to URL")
                            mainCompletion(url: nil)
                            return
                        }
                        self.pairedVideoURL = url
                        mainCompletion(url: url)
                    }
                    return
                }
            }
            print("No Live Photo found")
            mainCompletion(url: nil)
        }
    }

}
