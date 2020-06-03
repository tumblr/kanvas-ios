//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for trimming
protocol TrimViewDelegate: class {
    /// Called after a trimming movement starts
    func didStartMovingTrimArea()
    
    /// Called after the trim range changes
    func didMoveTrimArea()
    
    /// Called after a trimming movement ends
    func didEndMovingTrimArea()
}

/// Constants for Trim view
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let height: CGFloat = 71
    static let selectorMargin: CGFloat = 20
}

/// A UIView for the trim tool
final class TrimView: UIView, TrimAreaDelegate {
    
    static let height: CGFloat = Constants.height
    static let selectorMargin = Constants.selectorMargin
    
    weak var delegate: TrimViewDelegate?
    
    let thumbnailContainer: UIView
    private lazy var trimArea: TrimArea = {
        let view = TrimArea()
        view.delegate = self
        return view
    }()
    
    private var trimAreaLeadingConstraint: NSLayoutConstraint
    private var trimAreaTrailingConstraint: NSLayoutConstraint
    
    private var movingLeftSelector: Bool
    private var movingRightSelector: Bool
    
    // MARK: - Initializers
    
    init() {
        thumbnailContainer = UIView()
        trimAreaLeadingConstraint = NSLayoutConstraint()
        trimAreaTrailingConstraint = NSLayoutConstraint()
        movingLeftSelector = false
        movingRightSelector = false
        super.init(frame: .zero)
        
        setupViews()
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        setupThumbnailContainer()
        setupTrimArea()
    }
    
    /// Sets up the container for the thumbnail collection
    private func setupThumbnailContainer() {
        thumbnailContainer.accessibilityIdentifier = "GIF Maker Thumbnail Container"
        thumbnailContainer.translatesAutoresizingMaskIntoConstraints = false
        thumbnailContainer.clipsToBounds = true
        addSubview(thumbnailContainer)
        
        NSLayoutConstraint.activate([
            thumbnailContainer.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            thumbnailContainer.heightAnchor.constraint(equalToConstant: ThumbnailCollectionCell.cellHeight),
            thumbnailContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            thumbnailContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    /// Sets up the trim area view.
    private func setupTrimArea() {
        trimArea.accessibilityIdentifier = "GIF Maker Trim Area"
        trimArea.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trimArea)
        
        trimAreaLeadingConstraint = trimArea.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                                      constant: Constants.selectorMargin)
        trimAreaTrailingConstraint = trimArea.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                                        constant: -Constants.selectorMargin)
        
        NSLayoutConstraint.activate([
            trimArea.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            trimArea.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor),
            trimAreaLeadingConstraint,
            trimAreaTrailingConstraint
        ])
    }
    
    // MARK: - TrimAreaDelegate
    
    func didMoveLeftSide(recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: self).x
        
        switch recognizer.state {
        case .began:
            trimAreaStartedMoving()
            movingLeftSelector = true
            leftSideMoved(to: location)
        case .changed:
            leftSideMoved(to: location)
        case .ended:
            leftSideMoved(to: location)
            movingLeftSelector = false
            trimAreaEndedMoving()
        default:
            break
        }
    }
    
    func didMoveRightSide(recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: self).x
        
        switch recognizer.state {
        case .began:
            trimAreaStartedMoving()
            movingRightSelector = true
            rightSideMoved(to: location)
        case .changed:
            rightSideMoved(to: location)
        case .ended:
            rightSideMoved(to: location)
            movingRightSelector = false
            trimAreaEndedMoving()
        default:
            break
        }
    }
    
    // MARK: - Gesture recognizers
    
    private func leftSideMoved(to location: CGFloat) {
        if location <= Constants.selectorMargin {
            trimAreaLeadingConstraint.constant = Constants.selectorMargin
        }
        else if location + TrimArea.selectorWidth <= trimArea.rightSelectorLocation {
            trimAreaLeadingConstraint.constant = location
        }
        
        delegate?.didMoveTrimArea()
    }
    
    private func rightSideMoved(to location: CGFloat) {
        if location + TrimArea.selectorWidth >= bounds.width - Constants.selectorMargin {
            trimAreaTrailingConstraint.constant = -Constants.selectorMargin
        }
        else if location >= trimArea.leftSelectorLocation {
            trimAreaTrailingConstraint.constant = location + TrimArea.selectorWidth - bounds.width
        }
        
        delegate?.didMoveTrimArea()
    }
    
    // MARK: - Private utilities
    
    private func trimAreaStartedMoving() {
        guard !movingLeftSelector, !movingRightSelector else { return }
        delegate?.didStartMovingTrimArea()
    }
    
    private func trimAreaEndedMoving() {
        guard !movingLeftSelector, !movingRightSelector else { return }
        delegate?.didEndMovingTrimArea()
    }
    
    // MARK: - Public interface
    
    /// shows or hides the view
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.alpha = show ? 1 : 0
        }
    }
    
    func getStartingPercentage() -> CGFloat {
        let totalWidth = bounds.width - (Constants.selectorMargin + TrimArea.selectorWidth) * 2
        return (trimArea.leftSelectorLocation - TrimArea.selectorWidth - Constants.selectorMargin) * 100 / totalWidth
    }
    
    func getEndingPercentage() -> CGFloat {
        let totalWidth = bounds.width - (Constants.selectorMargin + TrimArea.selectorWidth) * 2
        return 100 - (bounds.width - TrimArea.selectorWidth - trimArea.rightSelectorLocation - Constants.selectorMargin) * 100 / totalWidth
    }
}
