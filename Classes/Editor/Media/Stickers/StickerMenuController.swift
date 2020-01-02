//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for confirming a sticker
protocol StickerMenuControllerDelegate: class {
    /// Callback for when a sticker is selected
    ///
    /// - Parameters
    ///  - imageView: an image view with the sticker
    ///  - transformations: transformations to be applied to the image view
    ///  - location: initial position of the image view in its parent view
    ///  - size: image view size
    func didSelectSticker(imageView: UIImageView, transformations: ViewTransformations, location: CGPoint, size: CGSize)
}

/// A view controller that contains the sticker main collection and the sticker type collection
final class StickerMenuController: UIViewController, StickerCollectionControllerDelegate, StickerTypeCollectionControllerDelegate {
    
    private let stickerProvider: StickerProvider?
    weak var delegate: StickerMenuControllerDelegate?
    private lazy var stickerMenuView: StickerMenuView = StickerMenuView()
    
    private lazy var stickerCollectionController: StickerCollectionController = {
        let controller = StickerCollectionController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var stickerTypeCollectionController: StickerTypeCollectionController = {
        let controller = StickerTypeCollectionController(stickerProvider: self.stickerProvider)
        controller.delegate = self
        return controller
    }()
    
    // MARK: - Initializers
    
    /// The designated initializer for the sticker menu controller
    ///
    /// - Parameter stickerProvider: Class that will provide the stickers from the API.
    init(stickerProvider: StickerProvider?) {
        self.stickerProvider = stickerProvider
        super.init(nibName: .none, bundle: .none)
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    // MARK: - View life cycle
    
    override func loadView() {
        view = stickerMenuView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        load(childViewController: stickerCollectionController, into: stickerMenuView.mainCollectionContainer)
        load(childViewController: stickerTypeCollectionController, into: stickerMenuView.bottomCollectionContainer)
    }
        
    // MARK: - StickerCollectionControllerDelegate
    
    func didSelectSticker(sticker: UIImage, with size: CGSize) {
        let imageView = StylableImageView(image: sticker)
        delegate?.didSelectSticker(imageView: imageView, transformations: ViewTransformations(),
                                   location: UIScreen.main.bounds.center, size: size)
    }
    
    // MARK: - StickerTypeCollectionControllerDelegate
    
    func didSelectStickerType(_ stickerType: StickerType) {
        stickerCollectionController.setType(stickerType)
    }
}
