//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for trimming
protocol TrimViewDelegate: AnyObject {
    /// Called after a trimming movement starts
    func didStartMovingTrimArea()
    
    /// Called after the trim range changes
    func didMoveStartTrim()
    func didMoveEndTrim()
    
    /// Called after a trimming movement ends
    func didEndMovingTrimArea()
    
    /// Obtains the text for the left time indicator
    func getLeftTimeIndicatorText() -> String
    
    /// Obtains the text for the right time indicator
    func getRightTimeIndicatorText() -> String
}

/// Constants for Trim view
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let timeIndicatorMargin: CGFloat = 8
    static let selectorMargin: CGFloat = 20
    static let height: CGFloat = TrimArea.height + timeIndicatorMargin + TimeIndicator.height
    static let overlayColor: UIColor = UIColor.black.withAlphaComponent(0.6)
    static let backgroundHandlesColor: UIColor = UIColor(hex: "#595959")
}

/// A UIView for the trim tool
final class TrimView: UIView, TrimAreaDelegate {
    
    static let height: CGFloat = Constants.height
    static let selectorMargin = Constants.selectorMargin
    
    weak var delegate: TrimViewDelegate?
    
    private lazy var trimArea: TrimArea = {
        let view = TrimArea()
        view.delegate = self
        return view
    }()
    
    let thumbnailContainer: UIView
    private let backgroundHandles: TrimArea
    private let leftTimeIndicator: TimeIndicator
    private let rightTimeIndicator: TimeIndicator
    private var overlayLayer: CALayer
    
    private var trimAreaLeadingConstraint: NSLayoutConstraint
    private var trimAreaTrailingConstraint: NSLayoutConstraint
    
    private var movingLeftSelector: Bool
    private var movingRightSelector: Bool
    
    // MARK: - Initializers
    
    init() {
        backgroundHandles = TrimArea()
        thumbnailContainer = UIView()
        leftTimeIndicator = TimeIndicator()
        rightTimeIndicator = TimeIndicator()
        trimAreaLeadingConstraint = NSLayoutConstraint()
        trimAreaTrailingConstraint = NSLayoutConstraint()
        movingLeftSelector = false
        movingRightSelector = false
        overlayLayer = CALayer()
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
        setupBackgroundHandles()
        setupTrimArea()
        setupLeftTimeIndicator()
        setupRightTimeIndicator()
    }
    
    /// Sets up the container for the thumbnail collection
    private func setupThumbnailContainer() {
        thumbnailContainer.accessibilityIdentifier = "GIF Maker Thumbnail Container"
        thumbnailContainer.translatesAutoresizingMaskIntoConstraints = false
        thumbnailContainer.clipsToBounds = true
        addSubview(thumbnailContainer)
        
        let bottomMargin = (TrimArea.height - ThumbnailCollectionCell.cellHeight) / 2
        NSLayoutConstraint.activate([
            thumbnailContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -bottomMargin),
            thumbnailContainer.heightAnchor.constraint(equalToConstant: ThumbnailCollectionCell.cellHeight),
            thumbnailContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            thumbnailContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    /// Sets up the handles in black and white.
    private func setupBackgroundHandles() {
        backgroundHandles.accessibilityIdentifier = "GIF Maker Background handles"
        backgroundHandles.translatesAutoresizingMaskIntoConstraints = false
        backgroundHandles.showLines(false)
        addSubview(backgroundHandles)
        
        NSLayoutConstraint.activate([
            backgroundHandles.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            backgroundHandles.heightAnchor.constraint(equalToConstant: TrimArea.height),
            backgroundHandles.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.selectorMargin),
            backgroundHandles.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.selectorMargin)
        ])
        
        backgroundHandles.isUserInteractionEnabled = false
        backgroundHandles.setBackgroundColor(Constants.backgroundHandlesColor)
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
            trimArea.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            trimArea.heightAnchor.constraint(equalToConstant: TrimArea.height),
            trimAreaLeadingConstraint,
            trimAreaTrailingConstraint
        ])
    }
    
    /// Sets up the time bubble above the left handle.
    private func setupLeftTimeIndicator() {
        leftTimeIndicator.accessibilityIdentifier = "GIF Maker Left Time Indicator"
        leftTimeIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftTimeIndicator)
        
        let bottomMargin = TrimArea.height + Constants.timeIndicatorMargin
        NSLayoutConstraint.activate([
            leftTimeIndicator.heightAnchor.constraint(equalToConstant: TimeIndicator.height),
            leftTimeIndicator.widthAnchor.constraint(equalToConstant: TimeIndicator.width),
            leftTimeIndicator.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -bottomMargin),
            leftTimeIndicator.centerXAnchor.constraint(equalTo: trimArea.leadingAnchor, constant: TrimArea.selectorWidth / 2)
        ])
        
        leftTimeIndicator.alpha = 0
    }
    
    /// Sets up the time bubble above the right handle.
    private func setupRightTimeIndicator() {
        rightTimeIndicator.accessibilityIdentifier = "GIF Maker Right Time Indicator"
        rightTimeIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightTimeIndicator)
        
        let bottomMargin = TrimArea.height + Constants.timeIndicatorMargin
        NSLayoutConstraint.activate([
            rightTimeIndicator.heightAnchor.constraint(equalToConstant: TimeIndicator.height),
            rightTimeIndicator.widthAnchor.constraint(equalToConstant: TimeIndicator.width),
            rightTimeIndicator.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -bottomMargin),
            rightTimeIndicator.centerXAnchor.constraint(equalTo: trimArea.trailingAnchor, constant: -TrimArea.selectorWidth / 2)
        ])
        
        rightTimeIndicator.alpha = 0
    }
    
    // MARK: - TrimAreaDelegate
    
    func didMoveLeftSide(recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: self).x
        leftTimeIndicator.text = delegate?.getLeftTimeIndicatorText()
        
        switch recognizer.state {
        case .began:
            trimAreaStartedMoving()
            movingLeftSelector = true
            leftTimeIndicator.showView(true)
            leftSideMoved(to: location)
        case .changed:
            leftSideMoved(to: location)
        case .ended:
            leftSideMoved(to: location)
            leftTimeIndicator.showView(false)
            movingLeftSelector = false
            trimAreaEndedMoving()
        default:
            break
        }
    }
    
    func didMoveRightSide(recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: self).x
        rightTimeIndicator.text = delegate?.getRightTimeIndicatorText()
        
        switch recognizer.state {
        case .began:
            trimAreaStartedMoving()
            movingRightSelector = true
            rightTimeIndicator.showView(true)
            rightSideMoved(to: location)
        case .changed:
            rightSideMoved(to: location)
        case .ended:
            rightSideMoved(to: location)
            rightTimeIndicator.showView(false)
            movingRightSelector = false
            trimAreaEndedMoving()
        default:
            break
        }
    }
    
    // MARK: - Gesture recognizers
    
    private func leftSideMoved(to location: CGFloat) {
        setLeftSide(location: location)
        delegate?.didMoveStartTrim()
    }

    private func rightSideMoved(to location: CGFloat) {
        setRightSide(location: location)
        delegate?.didMoveEndTrim()
    }

    private func setLeftSide(location: CGFloat) {
        if location <= Constants.selectorMargin {
            trimAreaLeadingConstraint.constant = Constants.selectorMargin
        }
        else if location + TrimArea.selectorWidth <= trimArea.rightSelectorLocation {
            trimAreaLeadingConstraint.constant = location
        }
    }

    private func setRightSide(location: CGFloat) {
        print("setRightSide location:\(location)")
        if location + TrimArea.selectorWidth >= bounds.width - Constants.selectorMargin {
            trimAreaTrailingConstraint.constant = -Constants.selectorMargin
        }
        else if location >= trimArea.leftSelectorLocation {
            trimAreaTrailingConstraint.constant = location + TrimArea.selectorWidth - bounds.width
        }
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
    
    /// Obtains the location of the left handle expressed as a percentage. 0 is the left limit and 100 is the right limit.
    func getStartingPercentage() -> CGFloat {
        let totalWidth = bounds.width - (Constants.selectorMargin + TrimArea.selectorWidth) * 2
        return (trimArea.leftSelectorLocation - TrimArea.selectorWidth - Constants.selectorMargin) * 100 / totalWidth
    }
    
    /// Obtains the location of the right handle expressed as a percentage. 0 is the left limit and 100 is the right limit.
    func getEndingPercentage() -> CGFloat {
        let totalWidth = bounds.width - (Constants.selectorMargin + TrimArea.selectorWidth) * 2
        return 100 - (bounds.width - TrimArea.selectorWidth - trimArea.rightSelectorLocation - Constants.selectorMargin) * 100 / totalWidth
    }
    
    /// Updates the overlay on the thumbnail collection.
    ///
    /// - Parameter cellsFrame: the frame that contains the visible cells on the collection.
    func setOverlay(cellsFrame: CGRect) {
        let cellsPath = UIBezierPath(rect: cellsFrame)
        cellsPath.usesEvenOddFillRule = true
        
        let trimAreaFrame = getTrimAreaFrame()
        let trimAreaPath = UIBezierPath(roundedRect: trimAreaFrame, cornerRadius: TrimArea.cornerRadius)
        cellsPath.append(trimAreaPath)
        
        let bouncingAreaFrames: [CGRect] = getBouncingAreaFrames(cellsFrame: cellsFrame, trimAreaFrame: trimAreaFrame)
        bouncingAreaFrames.forEach { bouncingFrame in
            let bouncingAreaPath = UIBezierPath(rect: bouncingFrame)
            cellsPath.append(bouncingAreaPath)
        }
        
        
        // Layer creation
        let newLayer = createOverlay(path: cellsPath)
        overlayLayer.removeFromSuperlayer()
        overlayLayer = newLayer
        thumbnailContainer.layer.addSublayer(newLayer)
    }

    /// Sets the location of the left-side handle
    /// - Parameter location: 0.0-1.0 based location to move the handle to.
    func setLeftSide(percentage: CGFloat) {
        let totalWidth = bounds.width - (Constants.selectorMargin * 2)
        let location = (totalWidth * percentage) + TrimArea.selectorWidth
        setLeftSide(location: location)
    }

    /// Sets the location of the right-side handle
    /// - Parameter location: 0.0-1.0 based location to move the handle to.
    func setRightSide(percentage: CGFloat) {
        let totalWidth = bounds.width - (Constants.selectorMargin * 2)
        let location = (totalWidth * percentage) + TrimArea.selectorWidth
        setRightSide(location: location)
    }
    
    // MARK: - Overlay
    
    /// Creates the overlay layer.
    ///
    /// - Parameter path: the path to create the shape of the layer.
    private func createOverlay(path: UIBezierPath) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillRule = .evenOdd
        layer.fillColor = Constants.overlayColor.cgColor
        return layer
    }
    
    /// Calculates the trim area frame in relation with the collection coordinates.
    private func getTrimAreaFrame() -> CGRect {
        return convert(trimArea.frame, to: thumbnailContainer)
    }
    
    /// Calculates extra frames for cases in which the collection is bouncing.
    ///
    /// - Parameters:
    ///  - cellsFrame: the frame that surrounds the visible cells.
    ///  - trimAreaFrame: the frame that surrounds the trim area.
    private func getBouncingAreaFrames(cellsFrame: CGRect, trimAreaFrame: CGRect) -> [CGRect] {
        var extraFrames: [CGRect] = []
        
        if trimAreaFrame.minX < cellsFrame.minX {
            let leftFrame = CGRect(x: cellsFrame.minX,
                                   y: cellsFrame.minY,
                                   width: trimAreaFrame.minX - cellsFrame.minX,
                                   height: cellsFrame.height)
            extraFrames.append(leftFrame)
        }
        
        if cellsFrame.maxX < trimAreaFrame.maxX {
            let rightFrame = CGRect(x: cellsFrame.maxX,
                                    y: cellsFrame.minY,
                                    width: trimAreaFrame.maxX - cellsFrame.maxX,
                                    height: cellsFrame.height)
            
            extraFrames.append(rightFrame)
        }
        
        return extraFrames
    }
}
