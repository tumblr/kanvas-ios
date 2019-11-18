//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for confirming the a sticker
protocol StickerMenuControllerDelegate: class {
    func didSelectSticker(_ sticker: Sticker)
}

/// Constants for StickerMenuController
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
}

/// A view controller that contains the text tools menu
final class StickerMenuController: UIViewController, StickerMenuViewDelegate, StickerCollectionControllerDelegate, StickerTypeCollectionControllerDelegate {
    
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
    
    private lazy var stickerMenuView: StickerMenuView = {
        let view = StickerMenuView()
        view.delegate = self
        return view
    }()
    
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
    
    func didSelectStickerType(_ stickerType: Sticker) {
        stickerCollectionController.setType(stickerType)
    }
}
