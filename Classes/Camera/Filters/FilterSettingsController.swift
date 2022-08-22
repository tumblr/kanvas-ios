//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol FilterSettingsControllerDelegate: AnyObject {
    /// Callback for when a filter item is selected
    ///
    /// - Parameter filterItem: the selected filter
    func didSelectFilter(_ filterItem: FilterItem, animated: Bool)
    
    /// Callback for when the selected filter is tapped
    ///
    /// - Parameter recognizer: the tap recognizer
    func didTapSelectedFilter(recognizer: UITapGestureRecognizer)
    
    /// Callback for when the selected filter is longpressed
    ///
    /// - Parameter recognizer: the longpress recognizer
    func didLongPressSelectedFilter(recognizer: UILongPressGestureRecognizer)
    
    /// Callback for when the button that shows/hides the filter selector is tapped
    ///
    /// - Parameter visible: whether the filter collection is visible
    func didTapVisibilityButton(visible: Bool)
}

/// Controller for handling the filter selector
final class FilterSettingsController: UIViewController, FilterSettingsViewDelegate, CameraFilterCollectionControllerDelegate {
    weak var delegate: FilterSettingsControllerDelegate?

    let settings: CameraSettings
    
    private lazy var filterSettingsView: FilterSettingsView = {
        let view = FilterSettingsView()
        view.delegate = self
        return view
    }()
    
    private lazy var collectionController: CameraFilterCollectionController = {
        let controller = CameraFilterCollectionController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    
    init(settings: CameraSettings) {
        self.settings = settings
        super.init(nibName: .none, bundle: .none)
    }
    
    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func loadView() {
        view = filterSettingsView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load(childViewController: collectionController, into: filterSettingsView.collectionContainer)
    }
    
    // MARK: - Public interface
    
    /// Updates the UI depending on whether recording is enabled
    ///
    /// - Parameter isRecording: if the UI should reflect that the user is currently recording
    func updateUI(forRecording isRecording: Bool) {
        filterSettingsView.showVisibilityButton(!isRecording)
        collectionController.updateUI(forRecording: isRecording)
    }

    /// Indicates whether the filter selector is visible
    ///
    /// - Returns: true if visible, false if hidden
    func isFilterSelectorVisible() -> Bool {
        return collectionController.isViewVisible()
    }
    
    // MARK: - FilterSettingsViewDelegate
    
    func didTapVisibilityButton() {
        let visible = !collectionController.isViewVisible()
        collectionController.showView(visible)
        filterSettingsView.onFilterCollectionShown(visible)
        delegate?.didTapVisibilityButton(visible: visible)
    }
    
    // MARK: - FilterCollectionControllerDelegate
    
    func didSelectFilter(_ filterItem: FilterItem, animated: Bool) {
        delegate?.didSelectFilter(filterItem, animated: animated)
    }
    
    func didTapSelectedFilter(recognizer: UITapGestureRecognizer) {
        delegate?.didTapSelectedFilter(recognizer: recognizer)
    }
    
    func didLongPressSelectedFilter(recognizer: UILongPressGestureRecognizer) {
        delegate?.didLongPressSelectedFilter(recognizer: recognizer)
    }
}
