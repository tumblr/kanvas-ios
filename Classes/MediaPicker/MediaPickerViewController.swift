//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

import MobileCoreServices
import Photos

protocol KanvasMediaPickerViewControllerDelegate: class {
    func didPick(image: UIImage, url: URL?)
    func didPick(video: URL)
    func didPick(gif: URL)
    func didPick(livePhotoStill: UIImage, pairedVideo: URL)
    func didCancel()
    func pickingMediaNotAllowed(reason: String)
}

final fileprivate class KanvasUIImagePickerController : UIImagePickerController {
    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var childForStatusBarHidden: UIViewController? {
        return nil
    }
}

final class KanvasMediaPickerViewController: UIViewController {

    let settings: CameraSettings

    weak var delegate: KanvasMediaPickerViewControllerDelegate?

    fileprivate lazy var imagePickerController: KanvasUIImagePickerController = {
        let picker = KanvasUIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        return picker
    }()

    init(settings: CameraSettings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        addChild(imagePickerController)
        view.addSubview(imagePickerController.view)
    }
}

extension KanvasMediaPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        dismiss(animated: true, completion: nil)

        let image = info[.originalImage] as? UIImage
        let mediaURL = info[.mediaURL] as? URL
        let imageURL = info[.imageURL] as? URL
        let phAsset = info[.phAsset] as? PHAsset

        loadPickedMedia(image: image, imageURL: imageURL, mediaURL: mediaURL, phAsset: phAsset)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        delegate?.didCancel()
    }
}

private extension KanvasMediaPickerViewController {

    func requestImageData(phAsset: PHAsset?, completion: @escaping (Data?) -> Void) {
        guard let phAsset = phAsset else {
            completion(nil)
            return
        }
        guard phAsset.mediaType == .image else {
            completion(nil)
            return
        }
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImageData(for: phAsset, options: options) { (data, str, orientation, opts) in
            completion(data)
        }
    }

    func loadPickedMedia(image: UIImage?, imageURL: URL?, mediaURL: URL?, phAsset: PHAsset?) {

        let loadMedia = {
            self.requestImageData(phAsset: phAsset) { data in
                self.handlePickedMedia(data: data, imageURL: imageURL, image: image, mediaURL: mediaURL, livePhotoVideoURL: nil)
            }
        }

        if let phAsset = phAsset, phAsset.mediaSubtypes.contains(.photoLive) {
            LivePhotoLoader(asset: phAsset).pairedVideo { livePhotoVideoURL in
                guard let livePhotoVideoURL = livePhotoVideoURL else {
                    loadMedia()
                    return
                }

                self.handlePickedMedia(data: nil, imageURL: nil, image: image, mediaURL: nil, livePhotoVideoURL: livePhotoVideoURL)
            }
        }
        else {
            loadMedia()
        }
    }

    func handlePickedMedia(data: Data?, imageURL: URL?, image: UIImage?, mediaURL: URL?, livePhotoVideoURL: URL?) {
        if settings.features.gifs,
            let data = data,
            GIFDecoderFactory.main().numberOfFrames(in: data) > 1,
            let gifURL = try? CameraController.save(data: data, to: "kanvas-picked", ext: "gif") {
            pick(frames: gifURL)

        }
        else if settings.features.gifs,
            let gifURL = imageURL,
            GIFDecoderFactory.main().numberOfFrames(in: gifURL) > 1 {
            pick(frames: gifURL)
        }
        else if let image = image, let livePhotoVideoURL = livePhotoVideoURL {
            pick(livePhotoStill: image, pairedVideo: livePhotoVideoURL)
        }
        else if let image = image {
            guard canPick(image: image) else {
                let message = NSLocalizedString("That's too big, bud.", comment: "That's too big, bud.")
                cannotPick(reason: message)
                return
            }
            pick(image: image, url: mediaURL)
        }
        else if let mediaURL = mediaURL {
            pick(video: mediaURL)
        }
        else {
            assertionFailure("No action taken on chosen media")
        }
    }

    private func pick(frames imageURL: URL) {
        delegate?.didPick(gif: imageURL)
    }

    private func pick(image: UIImage, url: URL?) {
        delegate?.didPick(image: image, url: url)
    }

    private func pick(video url: URL) {
        delegate?.didPick(video: url)
    }

    private func pick(livePhotoStill: UIImage, pairedVideo: URL) {
        delegate?.didPick(livePhotoStill: livePhotoStill, pairedVideo: pairedVideo)
    }

    private func canPick(image: UIImage) -> Bool {
        // image pixels must be less than 100MB
        guard let cgImage = image.cgImage else {
            return false
        }
        let bytesPerFrame = cgImage.bytesPerRow * cgImage.height
        let frameCount = image.images?.count ?? 1
        return Double(bytesPerFrame * frameCount) < 100000000.0
    }

    private func cannotPick(reason: String) {
        delegate?.pickingMediaNotAllowed(reason: reason)
    }
}
