//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import Photos

protocol MediaPickerThumbnailFetcherDelegate: AnyObject {
    func didUpdateThumbnail(image: UIImage)
}

final class MediaPickerThumbnailFetcher: NSObject, PHPhotoLibraryChangeObserver {

    private var mediaPickerThumbnailQueue = DispatchQueue(label: "kanvas.mediaPickerThumbnailQueue")

    private var didRegisterForPhotoLibraryChanges: Bool = false

    private var lastMediaPickerFetchResult: PHFetchResult<PHAsset>?

    var thumbnailTargetSize: CGSize = .zero

    weak var delegate: MediaPickerThumbnailFetcherDelegate?

    func updateThumbnail() {
        fetchMostRecentPhotoLibraryImage { image in
            if let image = image {
                self.delegate?.didUpdateThumbnail(image: image)
            }
        }
    }

    private func fetchMostRecentPhotoLibraryImage(completion: @escaping (UIImage?) -> Void) {

        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            performUIUpdate {
                completion(nil)
            }
            return
        }

        // PHPhotoLibrary.register prompts for Photo Pibrary access, so ensure this line always happens after the PHPhotoLibrary.authorizationStatus check.
        if !didRegisterForPhotoLibraryChanges {
            PHPhotoLibrary.shared().register(self)
            didRegisterForPhotoLibraryChanges = true
        }

        mediaPickerThumbnailQueue.async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 1
            // PHAsset.fetchAssets prompts for photo library access, so ensure this line always happens after the PHPhotoLibrary.authorizationStatus check.
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
            self.lastMediaPickerFetchResult = fetchResult
            if fetchResult.count > 0 {
                let requestOptions = PHImageRequestOptions()
                requestOptions.deliveryMode = .opportunistic
                requestOptions.resizeMode = .fast
                let lastMediaPickerAsset = fetchResult.object(at: 0) as PHAsset
                PHImageManager.default().requestImage(for: lastMediaPickerAsset, targetSize: self.thumbnailTargetSize, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                    performUIUpdate {
                        completion(image)
                    }
                })
            }
            else {
                performUIUpdate {
                    completion(nil)
                }
            }
        }
    }

    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard
            let lastMediaPickerFetchResult = lastMediaPickerFetchResult,
            let changeDetails = changeInstance.changeDetails(for: lastMediaPickerFetchResult),
            changeDetails.insertedIndexes?.count == 1,
            changeDetails.removedIndexes?.count == 1
        else {
            return
        }
        fetchMostRecentPhotoLibraryImage { image in
            guard let image = image else { return }
            self.delegate?.didUpdateThumbnail(image: image)
        }
    }

    func cleanup() {
        if didRegisterForPhotoLibraryChanges {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
            didRegisterForPhotoLibraryChanges = false
        }
    }
}
