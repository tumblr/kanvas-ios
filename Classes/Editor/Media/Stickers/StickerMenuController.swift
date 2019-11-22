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
    /// - Parameter sticker: the selected sticker
    func didSelectSticker(_ sticker: Sticker)
}

/// A view controller that contains the sticker main collection and the sticker type collection
final class StickerMenuController: UIViewController, StickerCollectionControllerDelegate, StickerTypeCollectionControllerDelegate {
    
    weak var delegate: StickerMenuControllerDelegate?
        
    private lazy var stickerCollectionController: StickerCollectionController = {
        let controller = StickerCollectionController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var stickerTypeCollectionController: StickerTypeCollectionController = {
        let controller = StickerTypeCollectionController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var stickerMenuView: StickerMenuView = StickerMenuView()
    
    // MARK: - Initializers
    
    init() {
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
    
    func didSelectSticker(_ sticker: Sticker) {
        delegate?.didSelectSticker(sticker)
    }
    
    // MARK: - StickerTypeCollectionControllerDelegate
    
    func didSelectStickerType(_ stickerType: StickerType) {
        stickerCollectionController.setType(stickerType)
    }
}
