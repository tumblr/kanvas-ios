//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol DrawerTabBarControllerDelegate: class {
    func didSelectOption(_ option: DrawerTabBarOption)
}

/// Constants for Sticker Controller
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let initialIndexPath: IndexPath = IndexPath(item: 0, section: 0)
}

/// Controller for handling the filter item collection.
final class DrawerTabBarController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DrawerTabBarOptionCellDelegate {
    
    private lazy var drawerTabBarView = DrawerTabBarView()
    private var options: [DrawerTabBarOption]
    private var selectedIndexPath: IndexPath? {
        didSet {
            if let indexPath = oldValue, let cell = drawerTabBarView.collectionView.cellForItem(at: indexPath) as? DrawerTabBarOptionCell {
                cell.setSelected(false)
            }
        }
        willSet {
            if let indexPath = newValue, let cell = drawerTabBarView.collectionView.cellForItem(at: indexPath) as? DrawerTabBarOptionCell {
                cell.setSelected(true)
            }
        }
    }
    
    weak var delegate: DrawerTabBarControllerDelegate?
    
    /// Initializes the sticker collection
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
        drawerTabBarView.collectionView.register(cell: DrawerTabBarOptionCell.self)
        drawerTabBarView.collectionView.delegate = self
        drawerTabBarView.collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectedIndexPath = Constants.initialIndexPath
    }
        
    // MARK: - Public interface
    
    /// shows or hides the tab bar
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.drawerTabBarView.alpha = show ? 1 : 0
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = DrawerTabBarOptionCell.width * CGFloat(options.count)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrawerTabBarOptionCell.identifier, for: indexPath)
        if let cell = cell as? DrawerTabBarOptionCell, let sticker = options.object(at: indexPath.item) {
            cell.bindTo(sticker)
            cell.delegate = self
            
            if indexPath == selectedIndexPath {
                cell.setSelected(true)
            }
        }
        return cell
    }
    
    // MARK: Sticker selection
    
    /// Selects a sticker
    ///
    /// - Parameter index: position of the option in the collection
    private func selectOption(index: Int) {
        guard let option = options.object(at: index) else { return }
        delegate?.didSelectOption(option)
    }
    
    // MARK: - StickerCollectionCellDelegate
    
    func didTap(cell: DrawerTabBarOptionCell, recognizer: UITapGestureRecognizer) {
        if let indexPath = drawerTabBarView.collectionView.indexPath(for: cell), selectedIndexPath != indexPath {
            selectedIndexPath = indexPath
            selectOption(index: indexPath.item)
        }
    }
}

