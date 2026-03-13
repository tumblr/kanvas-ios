//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting an option.
protocol OptionSelectorControllerDelegate: AnyObject {
    
    /// Called when an option is selected
    ///
    /// - Parameter option: the selected option.
    func didSelect(option: OptionSelectorItem)
}

/// Constants for SelectorController
private struct Constants {
    static let initialIndexPath: IndexPath = IndexPath(item: 0, section: 0)
}

/// Controller for handling the selector.
final class OptionSelectorController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OptionSelectorViewDelegate {
    
    weak var delegate: OptionSelectorControllerDelegate?
    
    private lazy var optionSelectorView: OptionSelectorView = {
        let view = OptionSelectorView()
        view.delegate = self
        return view
    }()
    
    private var options: [OptionSelectorItem]
    
    private var selectedIndexPath: IndexPath {
        willSet {
            guard let cell = optionSelectorView.collectionView.cellForItem(at: newValue) as? OptionSelectorCell else { return }
            cell.setSelected(true)
            optionSelectorView.select(cell: cell, animated: enableSelectionAnimation)
        }
        didSet {
            guard let cell = optionSelectorView.collectionView.cellForItem(at: oldValue) as? OptionSelectorCell else { return }
            cell.setSelected(false)
        }
    }

    private var enableSelectionAnimation: Bool = true
    
    // MARK: - Initializers
    
    init(options: [OptionSelectorItem]) {
        self.options = options
        self.selectedIndexPath = Constants.initialIndexPath
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

    // MARK: - Public API

    /// selects the option.
    /// this does not trigger any delegation
    func select(option: OptionSelectorItem, animated: Bool = true) {
        guard let index = options.firstIndex(where: { $0.description == option.description }) else { return }
        
        let indexPath = IndexPath(item: index, section: 0)
        guard selectedIndexPath != indexPath else {
            return
        }

        let originalValue = enableSelectionAnimation
        enableSelectionAnimation = animated
        selectedIndexPath = indexPath
        enableSelectionAnimation = originalValue
    }
    
    // MARK: - View Life Cycle
    
    override func loadView() {
        view = optionSelectorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionSelectorView.collectionView.register(cell: OptionSelectorCell.self)
        optionSelectorView.collectionView.delegate = self
        optionSelectorView.collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let cellWidth = calculateCellWidth()
        OptionSelectorCell.width = cellWidth
        optionSelectorView.cellWidth = cellWidth
        optionSelectorView.selectionViewWidth = cellWidth
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionSelectorCell.identifier, for: indexPath) as? OptionSelectorCell, let option = options.object(at: indexPath.item) else { return UICollectionViewCell() }
        
        cell.bindTo(option)
        
        if indexPath == selectedIndexPath {
            cell.setSelected(true, animated: false)
            optionSelectorView.select(cell: cell)
        }
        
        return cell
    }
    
    // MARK: - OptionSelectorViewDelegate
    
    func didTapCell(at indexPath: IndexPath) {
        didSelect(indexPath)
    }
    
    func didSwipeLeft() {
        let newIndexPath = selectedIndexPath.previous()
        didSelect(newIndexPath)
    }
    
    func didSwipeRight() {
        let newIndexPath = selectedIndexPath.next()
        didSelect(newIndexPath)
    }
    
    private func didSelect(_ indexPath: IndexPath) {
        guard
            let option = options.object(at: indexPath.item),
            selectedIndexPath != indexPath
        else {
            return
        }
        
        selectedIndexPath = indexPath
        
        delegate?.didSelect(option: option)
    }
    
    // MARK: - Private utilities
    
    private func calculateCellWidth() -> CGFloat {
        return optionSelectorView.bounds.width / CGFloat(options.count)
    }
}
