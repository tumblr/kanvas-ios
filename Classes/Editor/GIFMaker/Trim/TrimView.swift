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
    static let selectorInset: CGFloat = -20
}

/// A UIView for the trim tool
final class TrimView: UIView, TrimAreaDelegate {
    
    static let height: CGFloat = Constants.height
    
    weak var delegate: TrimViewDelegate?
    
    let thumbnailContainer: UIView
    private lazy var trimArea: TrimArea = {
        let view = TrimArea()
        view.delegate = self
        return view
    }()
    
    private var trimAreaLeadingConstraint: NSLayoutConstraint
    private var trimAreaTrailingConstraint: NSLayoutConstraint
    
    // MARK: - Initializers
    
    init() {
        thumbnailContainer = UIView()
        trimAreaLeadingConstraint = NSLayoutConstraint()
        trimAreaTrailingConstraint = NSLayoutConstraint()
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
        
        trimAreaLeadingConstraint = trimArea.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
        trimAreaTrailingConstraint = trimArea.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        
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
            leftSideMoved(to: location)
        case .changed:
            leftSideMoved(to: location)
        case .ended:
            leftSideMoved(to: location)
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
            rightSideMoved(to: location)
        case .changed:
            rightSideMoved(to: location)
        case .ended:
            rightSideMoved(to: location)
            trimAreaEndedMoving()
        default:
            break
        }
    }
    
    // MARK: - Gesture recognizers
    
    private func leftSideMoved(to location: CGFloat) {
        if location <= 0 {
            trimAreaLeadingConstraint.constant = 0
        }
        else if location + TrimArea.selectorWidth <= trimArea.rightSelectorLocation {
            trimAreaLeadingConstraint.constant = location
        }
        
        let start = getStartingPercentage()
        let end = getEndingPercentage()
        delegate?.didMoveTrimArea(from: start, to: end)
    }
    
    private func rightSideMoved(to location: CGFloat) {
        if location + TrimArea.selectorWidth >= bounds.width {
            trimAreaTrailingConstraint.constant = 0
        }
        else if location >= trimArea.leftSelectorLocation {
            trimAreaTrailingConstraint.constant = location + TrimArea.selectorWidth - bounds.width
        }
        
        let start = getStartingPercentage()
        let end = getEndingPercentage()
        delegate?.didMoveTrimArea(from: start, to: end)
    }
    
    // MARK: - Private utilities
    
    private func getStartingPercentage() -> CGFloat {
        let totalWidth = bounds.width - TrimArea.selectorWidth * 2
        return (trimArea.leftSelectorLocation - TrimArea.selectorWidth) * 100 / totalWidth
    }
    
    private func getEndingPercentage() -> CGFloat {
        let totalWidth = bounds.width - TrimArea.selectorWidth * 2
        return 100 - (bounds.width - TrimArea.selectorWidth - trimArea.rightSelectorLocation) * 100 / totalWidth
    }
    
    private func trimAreaStartedMoving() {
        delegate?.didStartMovingTrimArea()
    }
    
    private func trimAreaEndedMoving() {
        let start = getStartingPercentage()
        let end = getEndingPercentage()
        delegate?.didEndMovingTrimArea(from: start, to: end)
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
