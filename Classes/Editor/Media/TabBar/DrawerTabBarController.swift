//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for selecting a tab
protocol DrawerTabBarControllerDelegate: AnyObject {
    func didSelectOption(_ option: DrawerTabBarOption)
}

/// Constants for DrawerTabBarController
private struct Constants {
    static let initialIndexPath: IndexPath = IndexPath(item: 0, section: 0)
}

/// Controller for handling the tab collection.
final class DrawerTabBarController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DrawerTabBarCellDelegate {
    
    weak var delegate: DrawerTabBarControllerDelegate?
    
    private lazy var drawerTabBarView = DrawerTabBarView()
    private var options: [DrawerTabBarOption]
    private var selectedIndexPath: IndexPath? {
        didSet {
            if let indexPath = oldValue,
                let cell = drawerTabBarView.collectionView.cellForItem(at: indexPath) as? DrawerTabBarCell {
                cell.setSelected(false)
            }
        }
        willSet {
            if let indexPath = newValue,
                let cell = drawerTabBarView.collectionView.cellForItem(at: indexPath) as? DrawerTabBarCell {
                cell.setSelected(true)
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Initializers
    
    init() {
        options = [.stickers]
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
        view = drawerTabBarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawerTabBarView.collectionView.register(cell: DrawerTabBarCell.self)
        drawerTabBarView.collectionView.delegate = self
        drawerTabBarView.collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectedIndexPath = Constants.initialIndexPath
        selectOption(index: Constants.initialIndexPath.item)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = DrawerTabBarCell.width * CGFloat(options.count)
        let leftInset = (collectionView.frame.width - totalCellWidth) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrawerTabBarCell.identifier, for: indexPath)
        if let cell = cell as? DrawerTabBarCell, let option = options.object(at: indexPath.item) {
            cell.bindTo(option)
            cell.delegate = self
            
            if indexPath == selectedIndexPath {
                cell.setSelected(true)
            }
        }
        return cell
    }
    
    // MARK: Tab option selection
    
    /// Selects a tab option
    ///
    /// - Parameter index: position of the tab option in the collection
    private func selectOption(index: Int) {
        guard let option = options.object(at: index) else { return }
        delegate?.didSelectOption(option)
    }
    
    // MARK: - DrawerTabBarCellDelegate
    
    func didTap(cell: DrawerTabBarCell, recognizer: UITapGestureRecognizer) {
        if let indexPath = drawerTabBarView.collectionView.indexPath(for: cell), selectedIndexPath != indexPath {
            selectedIndexPath = indexPath
            selectOption(index: indexPath.item)
        }
    }
}
