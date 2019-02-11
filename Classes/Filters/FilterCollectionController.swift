//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol FilterCollectionControllerDelegate: class {
    func filterSelected(filter: Filter)
}

private struct FilterCollectionControllerConstants {
    static let animationDuration: TimeInterval = 0.25
}

final class FilterCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private lazy var filterCollectionView = FilterCollectionView()
    private var filters: [Filter]
    
    weak var delegate: FilterCollectionControllerDelegate?
    
    init() {
        filters = [Filter(representativeColor: .tumblrBrightRed),
                   Filter(representativeColor: .tumblrBrightPink),
                   Filter(representativeColor: .tumblrBrightOrange),
                   Filter(representativeColor: .tumblrBrightYellow),
                   Filter(representativeColor: .tumblrBrightGreen),
                   Filter(representativeColor: .tumblrBrightBlue),
                   Filter(representativeColor: .tumblrBrightPurple)]
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
        view = filterCollectionView
    }
    
    override func viewDidLoad() {
        filterCollectionView.collectionView.register(cell: FilterCollectionCell.self)
        filterCollectionView.collectionView.delegate = self
        filterCollectionView.collectionView.dataSource = self
        filterCollectionView.alpha = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        filterCollectionView.collectionView.layoutIfNeeded()
    }
    
    // MARK: - Public interface
    
    func isViewVisible() -> Bool {
        return filterCollectionView.alpha > 0
    }
    
    func showView(_ show: Bool) {
        UIView.animate(withDuration: FilterCollectionControllerConstants.animationDuration) {
            self.filterCollectionView.alpha = show ? 1 : 0
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionCell.identifier, for: indexPath)
        if let cell = cell as? FilterCollectionCell {
            cell.bindTo(filters[indexPath.item])
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard filters.count > 0, collectionView.bounds != .zero else { return .zero }
        
        let leftInset = cellBorderWhenCentered(firstCell: true, leftBorder: true, collectionView: collectionView)
        let rightInset = cellBorderWhenCentered(firstCell: false, leftBorder: false, collectionView: collectionView)
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    private func cellBorderWhenCentered(firstCell: Bool, leftBorder: Bool, collectionView: UICollectionView) -> CGFloat {
        let cellMock = FilterCollectionCell(frame: .zero)
        if firstCell, let firstFilter = filters.first {
            cellMock.bindTo(firstFilter)
        }
        else if let lastFilter = filters.last {
            cellMock.bindTo(lastFilter)
        }
        let cellSize = cellMock.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let cellWidth = cellSize.width
        let center = collectionView.center.x
        let border = leftBorder ? center - cellWidth/2 : center + cellWidth/2
        let inset = leftBorder ? border : collectionView.bounds.width - border
        return inset
    }
    
    // MARK: - Scrolling
    
    private func scrollToOptionAt(_ index: Int) {
        guard filterCollectionView.collectionView.numberOfItems(inSection: 0) > index else { return }
        let indexPath = IndexPath(item: index, section: 0)
        filterCollectionView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        delegate?.filterSelected(filter: filters[indexPath.item])
    }
    
    private func indexPathAtCenter() -> IndexPath? {
        let x = filterCollectionView.collectionView.center.x + filterCollectionView.collectionView.contentOffset.x
        let y = filterCollectionView.collectionView.center.y + filterCollectionView.collectionView.contentOffset.y
        let point: CGPoint = CGPoint(x: x, y: y)
        return filterCollectionView.collectionView.indexPathForItem(at: point)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let indexPath = indexPathAtCenter(), !decelerate {
            scrollToOptionAt(indexPath.item)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let indexPath = indexPathAtCenter() {
            scrollToOptionAt(indexPath.item)
        }
    }
}
