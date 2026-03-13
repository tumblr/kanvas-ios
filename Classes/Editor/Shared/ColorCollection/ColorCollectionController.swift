//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol ColorCollectionControllerDelegate: AnyObject {
    /// Callback for the selection of an color
    ///
    /// - Parameter color: the selected color
    func didSelectColor(_ color: UIColor)
}

/// Constants for Collection Controller
private struct ColorCollectionControllerConstants {
    static let section: Int = 0
    static let animationDuration: TimeInterval = 0.25
}

/// Controller for handling the color collection.
final class ColorCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ColorCollectionCellDelegate {
    
    private lazy var colorCollectionView = ColorCollectionView()
    private var colors: [UIColor]
    
    weak var delegate: ColorCollectionControllerDelegate?
    
    /// Initializes the color collection
    init() {
        self.colors = []
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
        view = colorCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorCollectionView.collectionView.register(cell: ColorCollectionCell.self)
        colorCollectionView.collectionView.delegate = self
        colorCollectionView.collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colorCollectionView.updateFadeOutEffect()
        colorCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        colorCollectionView.collectionView.layoutIfNeeded()
    }
    
    // MARK: - Public interface
    
    /// adds a color at the beginning of the collection
    ///
    /// - Parameter color: the color to append
    func addColor(_ color: UIColor) {
        colors.insert(color, at: 0)
        colorCollectionView.collectionView.reloadData()
        colorCollectionView.collectionView.setContentOffset(.zero, animated: false)
    }
    
    /// adds an array of colors at the beginning of the collection
    ///
    /// - Parameter colorCollection: the colors to append
    func addColors(_ colorCollection: [UIColor]) {
        colors.insert(contentsOf: colorCollection, at: 0)
        colorCollectionView.collectionView.reloadData()
        colorCollectionView.collectionView.setContentOffset(.zero, animated: false)
    }
    
    /// shows or hides the filter selector
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: ColorCollectionControllerConstants.animationDuration) {
            self.colorCollectionView.alpha = show ? 1 : 0
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionCell.identifier, for: indexPath)
        if let cell = cell as? ColorCollectionCell {
            cell.bindTo(colors[indexPath.item])
            cell.delegate = self
        }
        return cell
    }
    
    // MARK: - ColorCollectionCellDelegate
    
    func didSelect(cell: ColorCollectionCell) {
        if let indexPath = colorCollectionView.collectionView.indexPath(for: cell) {
            delegate?.didSelectColor(colors[indexPath.item])
        }
    }
}
