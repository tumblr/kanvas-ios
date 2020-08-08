//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

import MobileCoreServices
import Photos

protocol MediaPickerViewControllerDelegate: class {
    func didPickMedia(image: UIImage?, imageURL: URL?, mediaURL: URL?, phAsset: PHAsset?)
    func didCancel()
}

final fileprivate class KanvasUIImagePickerController : UIImagePickerController {
    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var childForStatusBarHidden: UIViewController? {
        return nil
    }
}

final class MediaPickerViewController: UIViewController {

    weak var delegate: MediaPickerViewControllerDelegate?

    fileprivate lazy var imagePickerController: KanvasUIImagePickerController = {
        let mediaPicker = KanvasUIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.sourceType = .photoLibrary
        mediaPicker.allowsEditing = false
        mediaPicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        return mediaPicker
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        addChild(imagePickerController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.addSubview(imagePickerController.view)
    }
}

extension MediaPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        picker.dismiss(animated: true, completion: nil)

        let image = info[.originalImage] as? UIImage
        let mediaURL = info[.mediaURL] as? URL
        let imageURL = info[.imageURL] as? URL
        let phAsset = info[.phAsset] as? PHAsset

        delegate?.didPickMedia(image: image, imageURL: imageURL, mediaURL: mediaURL, phAsset: phAsset)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        delegate?.didCancel()
    }
}
