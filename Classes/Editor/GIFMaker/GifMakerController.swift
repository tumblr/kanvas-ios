//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for editing GIFs
protocol GifMakerControllerDelegate: class {
    
    /// Called after the confirm button is tapped
    func didConfirmGif()
}

/// Constants for GifMakerController
private struct Constants {
    // TODO: Add constants
}

/// A view controller that contains the GIF maker menu
final class GifMakerController: UIViewController, GifMakerViewDelegate, TrimControllerDelegate {
    
    weak var delegate: GifMakerControllerDelegate?
        
    private lazy var gifMakerView: GifMakerView = {
        let view = GifMakerView()
        view.delegate = self
        return view
    }()
    
    private lazy var trimController: TrimController = {
        let controller = TrimController()
        controller.delegate = self
        return controller
    }()

    
    /// Confirm button location expressed in screen coordinates
    var confirmButtonLocation: CGPoint {
        return gifMakerView.confirmButtonLocation
    }
    
    private var trimEnabled: Bool {
        willSet {
            gifMakerView.changeTrimButton(newValue)
            trimController.showView(newValue)
        }
    }
    
    // MARK: - Initializers
    
    init() {
        trimEnabled = false
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
    
    // MARK: - Life cycle
    
    override func loadView() {
        view = gifMakerView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        load(childViewController: trimController, into: gifMakerView.trimMenuContainer)
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        gifMakerView.alpha = 0
    }
    
    // MARK: - GifMakerViewDelegate
    
    func didTapConfirmButton() {
        delegate?.didConfirmGif()
    }
    
    func didTapTrimButton() {
        trimEnabled.toggle()
    }
    
    // MARK: - Public interface
    
    /// shows or hides the GIF maker menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        gifMakerView.showView(show)
    }
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        gifMakerView.showConfirmButton(show)
    }

}
