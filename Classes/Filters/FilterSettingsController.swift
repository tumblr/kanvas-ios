//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol FilterSettingsControllerDelegate: class {
    /// Callback for when a filter is selected
    func didSelectFilter(_ filterItem: FilterItem)
    /// Callback for when the button that shows/hides the filter selector is tapped
    ///
    /// - Parameter visible: whether the filter collection is visible
    func didTapVisibilityButton(visible: Bool)
}

/// Controller for handling the filter selector
final class FilterSettingsController: UIViewController, FilterSettingsViewDelegate, FilterCollectionControllerDelegate {
    weak var delegate: FilterSettingsControllerDelegate?
    
    private lazy var filterSettingsView: FilterSettingsView = {
        let view = FilterSettingsView()
        view.delegate = self
        return view
    }()
    
    private lazy var collectionController: FilterCollectionController = {
        let controller = FilterCollectionController()
        controller.delegate = self
        return controller
    }()
    
    init() {
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
    
    // MARK: - FilterSettingsViewDelegate
    
    func didTapVisibilityButton() {
        let visible = !collectionController.isViewVisible()
        collectionController.showView(visible)
        delegate?.didTapVisibilityButton(visible: visible)
    }
    
    // MARK: - FilterCollectionControllerDelegate
    
    func didSelectFilter(_ filterItem: FilterItem) {
        delegate?.didSelectFilter(filterItem)
    }
}
