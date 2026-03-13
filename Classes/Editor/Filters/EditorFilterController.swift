//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for confirming and selecting filters

protocol EditorFilterControllerDelegate: AnyObject {
    /// Callback for when the user taps the background to confirm
    func didConfirmFilters()
    
    /// Callback for when a filter item is selected
    ///
    /// - Parameter filterItem: the selected filter
    func didSelectFilter(_ filterItem: FilterItem)
}

/// Constants for EditorFilterController
private struct EditorFilterControllerConstants {
    static let animationDuration: TimeInterval = 0.25
}

/// A view controller that contains the filter menu
final class EditorFilterController: UIViewController, EditorFilterViewDelegate, EditorFilterCollectionControllerDelegate {
    
    weak var delegate: EditorFilterControllerDelegate?
    
    private let settings: CameraSettings
    
    private lazy var filterView: EditorFilterView = {
        let editorFilterView = EditorFilterView()
        editorFilterView.delegate = self
        return editorFilterView
    }()
    
    private lazy var filterCollectionController: EditorFilterCollectionController = {
        let controller = EditorFilterCollectionController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    init(settings: CameraSettings) {
        self.settings = settings
        super.init(nibName: .none, bundle: .none)
    }
    
    override func loadView() {
        view = filterView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        load(childViewController: filterCollectionController, into: filterView.collectionContainer)
    }
    
    private func setUpView() {
        filterView.alpha = 0
    }
    
    // MARK: - EditorFilterViewDelegate
    
    func didTapBackground() {
        delegate?.didConfirmFilters()
    }
    
    // MARK: - EditorFilterCollectionControllerDelegate
    
    func didSelectFilter(_ filterItem: FilterItem) {
        delegate?.didSelectFilter(filterItem)
    }
    
    // MARK: - Public interface
    
    /// shows or hides the filter menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        if show {
            self.filterView.alpha = 1
            self.filterCollectionController.showView(true)
        }
        else {
            UIView.animate(withDuration: EditorFilterControllerConstants.animationDuration, animations: {
                self.filterView.alpha = 0
            }, completion: { _ in
                self.filterCollectionController.showView(false)
            })
        }
    }

}
