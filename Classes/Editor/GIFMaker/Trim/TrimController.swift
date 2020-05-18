//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for the trim controller
protocol TrimControllerDelegate: class {
    /// Called after a trimming movement starts
    func didStartTrimming()
    
    /// Called after the trim range changes
    ///
    /// - Parameters:
    ///  - startingPercentage: trimming starting moment expressed as a percentage.
    ///  - endingPercentage: trimming starting moment expressed as a percentage.
    func didTrim(from startingPercentage: CGFloat, to endingPercentage: CGFloat)
    
    /// Called after a trimming movement ends
    ///
    /// - Parameters:
    ///  - startingPercentage: trimming starting moment expressed as a percentage.
    ///  - endingPercentage: trimming starting moment expressed as a percentage.
    func didEndTrimming(from startingPercentage: CGFloat, to endingPercentage: CGFloat)
}

/// A view controller that contains the trim menu
final class TrimController: UIViewController, TrimViewDelegate {
    
    weak var delegate: TrimControllerDelegate?
        
    private lazy var trimView: TrimView = {
        let view = TrimView()
        view.delegate = self
        return view
    }()
    
    private let thumbnailController: ThumbnailCollectionController
    
    // MARK: - Initializers
    
    init() {
        thumbnailController = ThumbnailCollectionController()
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
        view = trimView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        load(childViewController: thumbnailController, into: trimView.thumbnailContainer)
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        trimView.alpha = 0
    }
    
    // MARK: - TrimViewDelegate
    
    func didStartMovingTrimArea() {
        delegate?.didStartTrimming()
    }
    
    func didMoveTrimArea(from startingPercentage: CGFloat, to endingPercentage: CGFloat) {
        delegate?.didTrim(from: startingPercentage, to: endingPercentage)
    }
    
    func didEndMovingTrimArea(from startingPercentage: CGFloat, to endingPercentage: CGFloat) {
        delegate?.didEndTrimming(from: startingPercentage, to: endingPercentage)
    }
    
    // MARK: - Public interface
    
    /// shows or hides the trim menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        trimView.showView(show)
    }
    
    /// Sets the thumbnails at the background of the trim tool
    ///
    /// - Parameter thumbnails: images to be shown
    func setThumbnails(_ thumbnails: [UIImage]) {
        thumbnailController.setThumbnails(thumbnails)
    }
}
