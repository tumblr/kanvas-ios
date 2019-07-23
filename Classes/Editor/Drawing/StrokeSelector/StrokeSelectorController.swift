//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol StrokeSelectorControllerDelegate: class {
    /// Called before the animation for onboarding begins
    func didAnimationStart()
    
    /// Called after the animation for onboarding ends
    func didAnimationEnd()
}

private struct StrokeSelectorControllerConstants {
    static let animationDuration: TimeInterval = 0.25
}

final class StrokeSelectorController: UIViewController, StrokeSelectorViewDelegate {
    
    weak var delegate: StrokeSelectorControllerDelegate?
    
    private lazy var strokeSelectorView: StrokeSelectorView = {
        let view = StrokeSelectorView()
        view.delegate = self
        return view
    }()
    
    init() {
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
        view = strokeSelectorView
    }
    
    // MARK: - Public interface
    
    func showStrokeSelectorAnimation() {
        strokeSelectorView.showStrokeSelectorAnimation()
    }
    
    // MARK: - StrokeSelectorViewDelegate
    
    func didAnimationStart() {
        delegate?.didAnimationStart()
    }
    
    func didAnimationEnd() {
        delegate?.didAnimationEnd()
    }
    
    func didLongPressStrokeButton(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            showStrokeSelectorBackground(true)
        case .changed:
            strokeSelectorPanned(recognizer: recognizer)
        case .ended, .cancelled, .failed:
            showStrokeSelectorBackground(false)
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Private utilities
    
    /// Shows or hides the stroke selector
    ///
    /// - Parameter show: true to show, false to hide
    private func showStrokeSelectorBackground(_ show: Bool) {
        strokeSelectorView.showStrokeSelectorBackground(show)
    }
    
    /// Gets the position of the user's finger on screen,
    /// but adjusts it to fit the horizontal center of the selector.
    ///
    /// - Parameter recognizer: the gesture recognizer
    /// - Parameter view: the view that contains the circle
    /// - Returns: location of the user's finger
    private func getSelectedLocation(with recognizer: UILongPressGestureRecognizer, in view: UIView) -> CGPoint {
        let x = StrokeSelectorView.verticalSelectorWidth / 2
        let y = recognizer.location(in: view).y
        return CGPoint(x: x, y: y)
    }
    
    /// Changes the stroke circle location inside the stroke selector
    ///
    /// - Parameter location: the new position of the circle
    private func moveStrokeSelectorCircle(to location: CGPoint) {
        strokeSelectorView.moveStrokeSelectorCircle(to: location)
    }
    
    /// Changes the stroke circle size according to a percent that goes from
    /// the minimum size (0) to the maximum size (100)
    ///
    /// - Parameter percent: the new size of the circle
    private func setStrokeCircleSize(percent: CGFloat) {
        let maxIncrement = (StrokeSelectorView.strokeCircleMaxSize / StrokeSelectorView.strokeCircleMinSize) - 1
        let scale = 1.0 + maxIncrement * percent / 100.0
        strokeSelectorView.transformStrokeCircles(CGAffineTransform(scaleX: scale, y: scale))
    }
    
    private func strokeSelectorPanned(recognizer: UILongPressGestureRecognizer) {
        let point = getSelectedLocation(with: recognizer, in: strokeSelectorView.strokeSelectorPannableArea)
        if strokeSelectorView.strokeSelectorPannableArea.bounds.contains(point) {
            moveStrokeSelectorCircle(to: point)
            setStrokeCircleSize(percent: 100.0 - point.y)
        }
    }
}
