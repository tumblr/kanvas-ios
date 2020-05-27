//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol DiscreteSliderViewDelegate: class {
    func didSelectCell(at indexPath: IndexPath)
}

private struct Constants {
    static let animationDuration: TimeInterval = 0.1
    static let selectorSize: CGFloat = DiscreteSliderCollectionCell.cellHeight
    static let selectorBorderWidth: CGFloat = 3
}

/// View for the discrete slider
final class DiscreteSliderView: UIView {
    
    weak var delegate: DiscreteSliderViewDelegate?
    
    let collectionView: UICollectionView
    private let layout: DiscreteSliderCollectionViewLayout
    private let selector: Selector
    
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
    
    private func setupCollection() {
        collectionView.accessibilityIdentifier = "Discrete Slider Collection View"
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.add(into: self)
    }
    
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
    
    private func setupGestureRecognizers() {
        let recognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(selectorTouched(recognizer:)))
        recognizer.minimumPressDuration = 0
        addGestureRecognizer(recognizer)
    }
    
    @objc private func selectorTouched(recognizer: UIGestureRecognizer) {
        let location = calculateLocation(with: recognizer)
        guard let indexPath = collectionView.indexPathForItem(at: location),
            let cell = collectionView.cellForItem(at: indexPath) else { return }
        let newLocation = location.x - Constants.selectorSize/2
        
        switch recognizer.state {
        case .began:
            moveSelector(to: newLocation, animated: false)
        case .changed:
            moveSelector(to: newLocation, animated: false)
        case .ended, .cancelled, .failed:
            let cellLocation = cell.center.x - Constants.selectorSize/2
            moveSelector(to: cellLocation, animated: true)
        default:
            break
        }
        
        delegate?.didSelectCell(at: indexPath)
    }
    
    private func calculateLocation(with recognizer: UIGestureRecognizer) -> CGPoint {
        let bouncingFactor: CGFloat = 0.7
        let leftLimit = Constants.selectorSize * bouncingFactor
        let rightLimit = bounds.width - Constants.selectorSize * bouncingFactor
        let location = recognizer.location(in: self)
        let x = (leftLimit...rightLimit).clamp(location.x)
        let y = bounds.center.y
        return CGPoint(x: x, y: y)
    }
    
    private func moveSelector(to location: CGFloat, animated: Bool) {
        let action: () -> Void = { [weak self] in
            self?.selector.transform = CGAffineTransform(translationX: location, y: 0)
        }
        
        if animated {
            UIView.animate(withDuration: Constants.animationDuration, animations: action)
        }
        else {
            action()
        }
    }
    
    // MARK: - Public interface
    
    func setCellWidth(_ width: CGFloat) {
        layout.estimatedItemSize.width = width
    }
    
    func setSelector(at index: Int) {
        let cellWidth = layout.estimatedItemSize.width
        let location = cellWidth * CGFloat(index) + (cellWidth - Constants.selectorSize) / 2
        moveSelector(to: location, animated: false)
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
