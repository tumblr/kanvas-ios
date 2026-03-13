//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for tapping or swiping the options.
protocol OptionSelectorViewDelegate: AnyObject {
    
    /// Called when a cell is tapped
    ///
    /// - Parameter indexPath: the index path of the cell where the tap occurred.
    func didTapCell(at indexPath: IndexPath)
    
    /// Called when the options are swiped left
    func didSwipeLeft()
    
    /// Called when the options are swiped right
    func didSwipeRight()
}


/// Constants for OptionSelectorView
private struct Constants {
    static let animationDuration: TimeInterval = 0.1
    static let backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.65)
    static let selectionViewColor: UIColor = .white
    static let cornerRadius: CGFloat = 18
}

/// View for the selector controller
final class OptionSelectorView: UIView {
    
    static let height: CGFloat = OptionSelectorCell.height
    
    weak var delegate: OptionSelectorViewDelegate?
    
    let collectionView: UICollectionView
    private let layout: OptionSelectorCollectionViewLayout
    private let selectionView: UIView
    
    var cellWidth: CGFloat {
        set { layout.estimatedItemSize.width = newValue }
        get { layout.estimatedItemSize.width }
    }

    var selectionViewWidthConstraint: NSLayoutConstraint?
    var selectionViewLeadingConstraint: NSLayoutConstraint?
    
    var selectionViewWidth: CGFloat {
        willSet {
            selectionViewWidthConstraint?.constant = newValue
        }
    }
    
    // MARK: - Initializers
    
    init() {
        selectionView = UIView()
        layout = OptionSelectorCollectionViewLayout()
        collectionView = OptionSelectorInnerCollectionView(frame: .zero, collectionViewLayout: layout)
        selectionViewWidth = 0
        super.init(frame: .zero)
        backgroundColor = Constants.backgroundColor
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        
        setupViews()
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
    
    private func setupViews() {
        setupSelectionView()
        setupCollectionView()
    }
    
    /// Sets up a white rounded view.
    private func setupSelectionView() {
        addSubview(selectionView)
        selectionView.accessibilityIdentifier = "Option Selector Selection View"
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        selectionView.backgroundColor = Constants.selectionViewColor
        selectionView.layer.cornerRadius = Constants.cornerRadius

        let selectionViewWidthConstraint = selectionView.widthAnchor.constraint(equalToConstant: 0)
        let selectionViewLeadingConstraint = selectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0)
        NSLayoutConstraint.activate([
            selectionViewWidthConstraint,
            selectionView.heightAnchor.constraint(equalToConstant: OptionSelectorCell.height),
            selectionViewLeadingConstraint,
            selectionView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)
        ])

        self.selectionViewWidthConstraint = selectionViewWidthConstraint
        self.selectionViewLeadingConstraint = selectionViewLeadingConstraint
    }
    
    /// Sets up the collection for the  options.
    private func setupCollectionView() {
        collectionView.accessibilityIdentifier = "Option Selector Collection View"
        collectionView.backgroundColor = .clear
        collectionView.add(into: self)
    }
    
    // MARK: - Gesture recognizer
    
    /// Adds the gesture recognizers to the collection.
    private func setupGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(optionsTapped(recognizer:)))
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(optionsSwiped(recognizer:)))
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(optionsSwiped(recognizer:)))
        leftSwipeRecognizer.direction = .left
        rightSwipeRecognizer.direction = .right
        collectionView.addGestureRecognizer(tapRecognizer)
        collectionView.addGestureRecognizer(leftSwipeRecognizer)
        collectionView.addGestureRecognizer(rightSwipeRecognizer)
    }
    
    @objc private func optionsTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: superview)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            delegate?.didTapCell(at: indexPath)
        }
    }
    
    @objc private func optionsSwiped(recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .left:
            delegate?.didSwipeLeft()
        case .right:
            delegate?.didSwipeRight()
        default:
            break
        }
    }
    
    // MARK: - Public interface
    
    /// Moves the selection view to a specified cell.
    ///
    /// - Parameters:
    ///  - cell: the cell to which the selection view will move.
    ///  - animated: whether to animate the movement or not.
    func select(cell: OptionSelectorCell, animated: Bool = true) {
        let action: () -> Void = { [weak self] in
            self?.selectionViewLeadingConstraint?.constant = cell.frame.origin.x
        }
        
        if animated {
            // `layoutIfNeeded` is needed both inside and outside of the
            // animate block when animating layout constraints.
            self.layoutIfNeeded()
            UIView.animate(withDuration: Constants.animationDuration) {
                action()
                self.layoutIfNeeded()
            }
        }
        else {
            action()
        }
    }
}


private class OptionSelectorInnerCollectionView: UICollectionView {
    
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
        alwaysBounceHorizontal = false
        alwaysBounceVertical = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        autoresizesSubviews = true
        contentInset = .zero
        decelerationRate = UIScrollView.DecelerationRate.fast
        dragInteractionEnabled = false
    }
}

private class OptionSelectorCollectionViewLayout: UICollectionViewFlowLayout {

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
        estimatedItemSize = CGSize(width: OptionSelectorCell.width, height: OptionSelectorCell.height)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
}
