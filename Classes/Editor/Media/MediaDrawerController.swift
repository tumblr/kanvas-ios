//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting a sticker and dimissing the media drawer
protocol MediaDrawerControllerDelegate: AnyObject {
    /// Callback for when a sticker is selected
    ///
    /// - Parameters
    ///  - imageView: an image view with the sticker
    ///  - size: image view size
    func didSelectSticker(imageView: StylableImageView, size: CGSize)
    
    /// Callback for when a sticker type is selected
    ///
    /// - Parameter stickerType: the selected sticker type
    func didSelectStickerType(_ stickerType: StickerType)
    
    /// Callback for when the media drawer is dismissed
    func didDismissMediaDrawer()
    
    /// Callback for when the stickers tab is selected
    func didSelectStickersTab()
}

/// A view controller that contains the media drawer in text tools
final class MediaDrawerController: UIViewController, MediaDrawerViewDelegate, DrawerTabBarControllerDelegate, StickerMenuControllerDelegate {
    
    weak var delegate: MediaDrawerControllerDelegate?
    
    private var openedMenu: UIViewController?
    private let stickerProvider: StickerProvider?
    
    private lazy var drawerTabBarController: DrawerTabBarController = {
        let controller = DrawerTabBarController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var stickerMenuController: StickerMenuController = {
        let controller = StickerMenuController(stickerProvider: stickerProvider)
        controller.delegate = self
        return controller
    }()
    
    private lazy var mediaDrawerView: MediaDrawerView = {
        let view = MediaDrawerView()
        view.delegate = self
        return view
    }()
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Initializers
    
    /// The designated initializer for the media drawer controller
    ///
    /// - Parameters
    ///     - stickerProvider: Class that will provide the stickers in the stickers tab.
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
        view = mediaDrawerView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        load(childViewController: drawerTabBarController, into: mediaDrawerView.tabBarContainer)
        load(childViewController: stickerMenuController, into: mediaDrawerView.childContainer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.didDismissMediaDrawer()
    }
        
    // MARK: - MediaDrawerViewDelegate
    
    func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - DrawerTabBarControllerDelegate
    
    func didSelectOption(_ option: DrawerTabBarOption) {
        let newMenu: UIViewController
        
        switch option {
        case .stickers:
            delegate?.didSelectStickersTab()
            newMenu = stickerMenuController
        }
        
        openedMenu?.view.alpha = 0
        openedMenu = newMenu
        openedMenu?.view.alpha = 1
    }
    
    // MARK: - StickerMenuControllerDelegate
    
    func didSelectSticker(imageView: StylableImageView, size: CGSize) {
        delegate?.didSelectSticker(imageView: imageView, size: size)
        dismiss(animated: true, completion: nil)
    }
    
    func didSelectStickerType(_ stickerType: StickerType) {
        delegate?.didSelectStickerType(stickerType)
    }
}
