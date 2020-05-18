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
    ///
    /// - Parameters:
    ///  - startingPercentage: trimming starting moment expressed as a percentage.
    ///  - endingPercentage: trimming starting moment expressed as a percentage.
    func didMoveTrimArea(from startingPercentage: CGFloat, to endingPercentage: CGFloat)
    
    /// Called after a trimming movement ends
    ///
    /// - Parameters:
    ///  - startingPercentage: trimming starting moment expressed as a percentage.
    ///  - endingPercentage: trimming starting moment expressed as a percentage.
    func didEndMovingTrimArea(from startingPercentage: CGFloat, to endingPercentage: CGFloat)
}

/// Constants for Trim view
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let height: CGFloat = 71
    static let cornerRadius: CGFloat = 8
    static let backgroundColor: UIColor = .black
}

private enum MovingSide {
    case left
    case right
}

/// A UIView for the trim tool
final class TrimView: UIView {
    
    static let height: CGFloat = Constants.height
    
    weak var delegate: TrimViewDelegate?
    
    let thumbnailContainer: IgnoreTouchesView
    private let trimArea: TrimArea
    
    // Indicates which is the side of the range that is currently moving.
    private var currentlyMovingSide: MovingSide? = nil
    
    private var leadingConstraint: NSLayoutConstraint
    private var trailingConstraint: NSLayoutConstraint
    
    // MARK: - Initializers
    
    init() {
        thumbnailContainer = IgnoreTouchesView()
        trimArea = TrimArea()
        leadingConstraint = NSLayoutConstraint()
        trailingConstraint = NSLayoutConstraint()
        super.init(frame: .zero)
        
        setupViews()
        setupGestureRecognizers()
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
        thumbnailContainer.backgroundColor = Constants.backgroundColor
        thumbnailContainer.layer.cornerRadius = Constants.cornerRadius
        thumbnailContainer.clipsToBounds = true
        addSubview(thumbnailContainer)
        
        NSLayoutConstraint.activate([
            thumbnailContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            thumbnailContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            thumbnailContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            thumbnailContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    /// Sets up the trim area view.
    private func setupTrimArea() {
        trimArea.accessibilityIdentifier = "GIF Maker Trim Area"
        trimArea.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trimArea)
        
        leadingConstraint = trimArea.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
        trailingConstraint = trimArea.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        
        NSLayoutConstraint.activate([
            trimArea.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            trimArea.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor),
            leadingConstraint,
            trailingConstraint
        ])
    }
    
    // MARK: - Gesture recognizers
    
    private func setupGestureRecognizers() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(trimAreaTouched(recognizer:)))
        longPressRecognizer.minimumPressDuration = 0
        addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func trimAreaTouched(recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: self).x
        
        switch recognizer.state {
        case .began:
            trimAreaStartedMoving(on: location)
            trimAreaMoved(to: location)
        case .changed:
            trimAreaMoved(to: location)
        case .ended:
            trimAreaMoved(to: location)
            trimAreaEndedMoving(on: location)
        default:
            break
        }
    }
    
    private func trimAreaStartedMoving(on location: CGFloat) {
        currentlyMovingSide = closestSide(from: location)
        delegate?.didStartMovingTrimArea()
    }
    
    private func trimAreaMoved(to location: CGFloat) {
        let closestSideToTouch = closestSide(from: location)
        
        if closestSideToTouch == .left &&  currentlyMovingSide != .right {
            
            if location >= TrimArea.selectorWidth {
                leadingConstraint.constant = location - TrimArea.selectorWidth
            }
            else {
                leadingConstraint.constant = 0
            }
        }
        else if closestSideToTouch == .right && currentlyMovingSide != .left {
            
            if location <= bounds.width - TrimArea.selectorWidth {
                trailingConstraint.constant = location - bounds.width + TrimArea.selectorWidth
            }
            else {
                trailingConstraint.constant = 0
            }
        }
        
        let start = getStartingPercentage()
        let end = getEndingPercentage()
        delegate?.didMoveTrimArea(from: start, to: end)
    }
    
    private func trimAreaEndedMoving(on location: CGFloat) {
        currentlyMovingSide = nil
        let start = getStartingPercentage()
        let end = getEndingPercentage()
        delegate?.didEndMovingTrimArea(from: start, to: end)
    }
    
    // MARK: - Private utilities
    
    /// Calculates which is the closest side of the range to a given location.
    private func closestSide(from location: CGFloat) -> MovingSide {
        let leftSide = trimArea.frame.origin.x
        let rightSide = trimArea.frame.origin.x + trimArea.frame.width
        
        let distanceToLeftSide = abs(location - leftSide)
        let distanceToRightSide = abs(rightSide - location)
        
        return distanceToLeftSide < distanceToRightSide ? .left : .right
    }
    
    private func getStartingPercentage() -> CGFloat {
        return trimArea.frame.origin.x * 100 / (bounds.width - TrimArea.selectorWidth * 2)
    }
    
    private func getEndingPercentage() -> CGFloat {
        return 100 - ((bounds.width - trimArea.frame.origin.x - trimArea.frame.size.width) * 100 / (bounds.width - TrimArea.selectorWidth * 2))
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
}
