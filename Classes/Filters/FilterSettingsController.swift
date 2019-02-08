//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol FilterSettingsControllerDelegate: class {
    func filterSelected()
}

/// The class for controlling filters
final class FilterSettingsController: UIViewController, FilterSettingsViewDelegate, FilterCollectionControllerDelegate {
    weak var delegate: FilterSettingsControllerDelegate?
    
    private lazy var filterSettingsView: FilterSettingsView = {
        let view = FilterSettingsView()
        view.delegate = self
        return view
    }()
    
    private lazy var collectionController: FilterCollectionController = {
        let controller = FilterCollectionController()
        
        return controller
    }()
    
    override func loadView() {
        view = filterSettingsView
        load(childViewController: collectionController, into: filterSettingsView.collectionContainer)
    }
    
    // MARK: - FiltersViewDelegate
    
    func visibilityButtonPressed() {
        let visible = collectionController.isViewVisible()
        collectionController.showView(!visible)
    }
    
    func filterSelected() {
        delegate?.filterSelected()
    }
}
