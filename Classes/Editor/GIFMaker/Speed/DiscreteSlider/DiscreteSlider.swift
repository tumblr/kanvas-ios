//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting items.
protocol DiscreteSliderDelegate: AnyObject {
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
    private var selectedIndexPath: IndexPath {
        didSet {
            discreteSliderView.collectionView.reloadData()
        }
    }
    
    private lazy var discreteSliderView: DiscreteSliderView = {
        let view = DiscreteSliderView()
        view.delegate = self
        return view
    }()
    
    // MARK: - Initializers
    
    /// Initializer for the slider
    ///
    /// - Parameters:
    ///  - items: the list of values for the slider.
    ///  - initialIndex: the position of the selected value at startup.
    init(items: [Float], initialIndex: Int = 0) {
        self.items = items
        self.initialIndexPath = IndexPath(item: initialIndex, section: 0)
        self.selectedIndexPath = IndexPath(item: initialIndex, section: 0)
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
        discreteSliderView.cellWidth = newWidth
        discreteSliderView.setSelector(at: selectedIndexPath.item)
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
        
        if let cell = cell as? DiscreteSliderCollectionCell,
            let item = items.object(at: indexPath.item) {
            cell.bindTo(item)
            cell.setStyle(isCenter: indexPath == initialIndexPath,
                          isFirst: indexPath.item == 0,
                          isLast: indexPath.item == items.count - 1)
            
            let activeRange = getActiveRange()
            cell.setProgress(leftLineActive: activeRange.contains(cell.frame.minX),
                             rightLineActive: activeRange.contains(cell.frame.maxX))
        }
        
        return cell
    }
    
    // MARK: - DiscreteSliderViewDelegate
    
    func didSelectCell(at indexPath: IndexPath) {
        guard indexPath != selectedIndexPath,
            let item = items.object(at: indexPath.item) else { return }
        
        selectedIndexPath = indexPath
        delegate?.didSelect(item: item)
    }

    // MARK: - Public Interface

    func select(item: Float) {
        guard let index = items.firstIndex(of: item) else {
            return
        }
        let indexPath = IndexPath(item: index, section: 0)
        guard indexPath != selectedIndexPath else {
            return
        }
        selectedIndexPath = indexPath
        discreteSliderView.setSelector(at: index)
    }
    
    // MARK: - Private utilities
    
    /// Calculates the range of X coordinates between the initial position of the selector and its current position.
    ///
    /// - Returns:the range of X coordinates.
    private func getActiveRange() -> Range<CGFloat> {
        let initialPosition = getInitialLocation()
        let currentPosition = discreteSliderView.selectorPosition
        
        return initialPosition < currentPosition ? initialPosition..<currentPosition : currentPosition..<initialPosition
    }
    
    /// Calculates the initial location of the selector.
    ///
    /// - Returns: the intial location.
    private func getInitialLocation() -> CGFloat {
        return discreteSliderView.cellWidth * CGFloat(initialIndexPath.item)
            + (discreteSliderView.cellWidth - DiscreteSliderView.selectorSize) / 2
    }
}
