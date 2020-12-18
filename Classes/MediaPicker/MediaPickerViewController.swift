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

final class KanvasUIImagePickerController: UIImagePickerController {
    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var childForStatusBarHidden: UIViewController? {
        return nil
    }
}

internal extension UIImage {
    func scaledImageRect(for size: CGSize) -> CGRect {
        var scaledImageRect = CGRect.zero

        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)

        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0

        return scaledImageRect
    }

    func scale(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            draw(in: scaledImageRect(for: size))
        }
//        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
//        let imageSource = CGImageSourceCreateWithData(self.jpegData(compressionQuality: 1) as! CFData, imageSourceOptions)!
//
//        let maxDimensionsInPixels = max(size.width, size.height) * scale
//        let downsampleOptions = [
//            kCGImageSourceCreateThumbnailFromImageAlways: true,
//            kCGImageSourceShouldCacheImmediately: true,
//            kCGImageSourceCreateThumbnailWithTransform: true,
//            kCGImageSourceThumbnailMaxPixelSize: maxDimensionsInPixels
//        ] as CFDictionary
//
//        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
////        let type = CGImageSourceGetType(imageSource)!
////        let data = NSMutableData()
////        let destination = CGImageDestinationCreateWithData(data as CFMutableData, type as CFString, 1, [
////            kCGImageDestinationBackgroundColor: UIColor.black.cgColor
////        ] as CFDictionary)
//        return UIImage(cgImage: downsampledImage)
    }

    func letterboxedImage(size: CGSize, drawingRect: CGRect) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            draw(in: drawingRect)
        }
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
        picker.videoQuality = .typeIFrame1280x720
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
        super.viewDidLoad()
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
            pick(image: image, url: imageURL)
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

    // See 2018 WWDC for image performance optimization code
    private func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!

        let maxDimensionsInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionsInPixels
        ] as CFDictionary

        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }

    private func pick(image: UIImage, url: URL?) {
        let scaledImage: UIImage
        if let url = url {
            let scaledRect = image.scaledImageRect(for: UIScreen.main.nativeBounds.size)
            let newImage = downsample(imageAt: url, to: scaledRect.size, scale: 1)
            scaledImage = newImage.letterboxedImage(size: UIScreen.main.nativeBounds.size, drawingRect: scaledRect)!
//            scaledImage = downsample(imageAt: url, to: UIScreen.main.nativeBounds.size, scale: 1)
        } else {
            scaledImage = image.scale(size: UIScreen.main.nativeBounds.size) ?? image
        }

        delegate?.didPick(image: scaledImage, url: url)
    }

    private func pick(video url: URL) {
        delegate?.didPick(video: url)
    }

    private func pick(livePhotoStill: UIImage, pairedVideo: URL) {
        let newStill = livePhotoStill.scale(size: UIScreen.main.nativeBounds.size)!
        delegate?.didPick(livePhotoStill: newStill, pairedVideo: pairedVideo)
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
