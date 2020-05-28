//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting cells.
protocol DiscreteSliderViewDelegate: class {
    
    /// Called when a cell is selected.
    ///
    /// - Parameter indexPath: the index path of the cell.
    func didSelectCell(at indexPath: IndexPath)
}

/// Constants for DiscreteSliderView
private struct Constants {
    static let selectorSize: CGFloat = DiscreteSliderCollectionCell.cellHeight
    static let selectorBorderWidth: CGFloat = 3
    static let selectionBounds: CGFloat = 10
}

/// View for the discrete slider
final class DiscreteSliderView: UIView {
    
    weak var delegate: DiscreteSliderViewDelegate?
    
    let collectionView: UICollectionView
    private let layout: DiscreteSliderCollectionViewLayout
    private let selector: Selector
    
    // MARK: - Initializers
    
    init() {
        layout = DiscreteSliderCollectionViewLayout()
        collectionView = DiscreteSliderInnerCollectionView(frame: .zero, collectionViewLayout: layout)
        selector = Selector()
        super.init(frame: .zero)
        
        setUpViews()
        setupGestureRecognizers()
    }
    
    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setUpViews() {
        setupCollection()
        setupSelector()
    }
    
    /// Sets up the collection with items.
    private func setupCollection() {
        collectionView.accessibilityIdentifier = "Discrete Slider Collection View"
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.add(into: self)
    }
    
    /// Sets up the circular selector.
    private func setupSelector() {
        selector.accessibilityIdentifier = "Discrete Slider Selector"
        selector.image = KanvasCameraImages.circleImage
        selector.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selector)
        
        NSLayoutConstraint.activate([
            selector.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            selector.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            selector.heightAnchor.constraint(equalToConstant: Constants.selectorSize),
            selector.widthAnchor.constraint(equalToConstant: Constants.selectorSize),
        ])
    }
    
    // MARK: - Gesture recognizers
    
    /// Adds the gesture recognizers to the views.
    private func setupGestureRecognizers() {
        let recognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(selectorTouched(recognizer:)))
        recognizer.minimumPressDuration = 0
        addGestureRecognizer(recognizer)
    }
    
    @objc private func selectorTouched(recognizer: UIGestureRecognizer) {
        let location = calculateLocation(with: recognizer)
        guard let indexPath = collectionView.indexPathForItem(at: location),
            let cell = collectionView.cellForItem(at: indexPath),
            location.x.distance(to: cell.center.x) < Constants.selectionBounds else { return }
        
        let cellLocation = cell.center.x - Constants.selectorSize / 2
        moveSelector(to: cellLocation)
        delegate?.didSelectCell(at: indexPath)
    }
    
    private func calculateLocation(with recognizer: UIGestureRecognizer) -> CGPoint {
        let bouncingFactor: CGFloat = 0.5
        let leftLimit = Constants.selectorSize * bouncingFactor
        let rightLimit = bounds.width - Constants.selectorSize * bouncingFactor
        let location = recognizer.location(in: self)
        let x = (leftLimit...rightLimit).clamp(location.x)
        let y = bounds.center.y
        return CGPoint(x: x, y: y)
    }
    
    /// Moves the selector to a new location.
    ///
    /// - Parameter location: the new location.
    private func moveSelector(to location: CGFloat) {
        selector.transform = CGAffineTransform(translationX: location, y: 0)
    }
    
    // MARK: - Public interface
    
    /// Changes the cell width in the collection.
    ///
    /// - Parameter width: the new width.
    func setCellWidth(_ width: CGFloat) {
        layout.estimatedItemSize.width = width
    }
    
    /// Moves the selector to a cell.
    ///
    /// - Parameter index: the index of the cell.
    func setSelector(at index: Int) {
        let cellWidth = layout.estimatedItemSize.width
        let location = cellWidth * CGFloat(index) + (cellWidth - Constants.selectorSize) / 2
        moveSelector(to: location)
    }
}


private class DiscreteSliderInnerCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        isScrollEnabled = false
        allowsSelection = false
        bounces = false
        alwaysBounceHorizontal = true
        alwaysBounceVertical = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        autoresizesSubviews = true
        contentInset = .zero
        dragInteractionEnabled = false
    }
}

private class DiscreteSliderCollectionViewLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        scrollDirection = .horizontal
        itemSize = UICollectionViewFlowLayout.automaticSize
        estimatedItemSize = CGSize(width: DiscreteSliderCollectionCell.cellWidth, height: DiscreteSliderCollectionCell.cellHeight)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
}

/// The circular selector in the slider.
private class Selector: UIImageView {
    
    private let innerCircle: UIImageView
    private let outerCircle: UIImageView
    
    // MARK: - Initializers
    
    init() {
        innerCircle = UIImageView()
        outerCircle = UIImageView()
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupView() {
        setupOuterCircle()
        setupInnerCircle()
    }
    
    private func setupInnerCircle() {
        innerCircle.accessibilityIdentifier = "Discrete Slider Selector Inner Circle"
        innerCircle.image = KanvasCameraImages.circleImage
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(innerCircle)
        
        let inset = -Constants.selectorBorderWidth * 2
        NSLayoutConstraint.activate([
            innerCircle.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            innerCircle.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, constant: inset),
            innerCircle.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, constant: inset),
        ])
    }
    
    private func setupOuterCircle() {
        outerCircle.backgroundColor = .clear
        outerCircle.accessibilityIdentifier = "Discrete Slider Selector Outer Circle"
        let image = KanvasCameraImages.circleImage?.withRenderingMode(.alwaysTemplate)
        outerCircle.image = image
        outerCircle.tintColor = .tumblrBrightBlue
        outerCircle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerCircle)
        
        NSLayoutConstraint.activate([
            outerCircle.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            outerCircle.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            outerCircle.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor),
            outerCircle.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor),
        ])
    }
}
