//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting items.
protocol DiscreteSliderDelegate: class {
    /// Called when a new value is selected.
    ///
    /// - Parameter item: the selected item.
    func didSelect(item: Float)
}

/// Slider with discrete values.
final class DiscreteSlider: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DiscreteSliderViewDelegate {
    
    weak var delegate: DiscreteSliderDelegate?
    private let items: [Float]
    private let initialIndexPath: IndexPath
    private var selectedIndexPath: IndexPath
    
    private lazy var discreteSliderView: DiscreteSliderView = {
        let view = DiscreteSliderView()
        view.delegate = self
        return view
    }()
    
    // MARK: - Initializers
    
    init(items: [Float], initialIndex: Int = 0) {
        self.items = items
        self.initialIndexPath = IndexPath(item: initialIndex, section: 0)
        self.selectedIndexPath = IndexPath.init(item: initialIndex, section: 0)
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
        view = discreteSliderView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        discreteSliderView.collectionView.register(cell: DiscreteSliderCollectionCell.self)
        discreteSliderView.collectionView.delegate = self
        discreteSliderView.collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let newWidth = discreteSliderView.bounds.width / CGFloat(items.count)
        discreteSliderView.setCellWidth(newWidth)
        discreteSliderView.setSelector(at: initialIndexPath.item)
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscreteSliderCollectionCell.identifier, for: indexPath)
        if let cell = cell as? DiscreteSliderCollectionCell, let item = items.object(at: indexPath.item) {
            cell.bindTo(item)
            cell.setPosition(isStart: indexPath.item == 0, isEnd: indexPath.item == items.count - 1)
        }
        
        return cell
    }
    
    // MARK: - DiscreteSliderViewDelegate
    
    func didSelectCell(at indexPath: IndexPath) {
        guard indexPath != selectedIndexPath,
            let item = items.object(at: indexPath.item) else { return }
        
        selectedIndexPath = indexPath
        delegate?.didSelect(item: item)
        discreteSliderView.collectionView.reloadData()
    }
}
