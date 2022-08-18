//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol StrokeSelectorControllerDelegate: AnyObject {
    /// Called before the animation for onboarding begins
    func didAnimationStart()
    
    /// Called after the animation for onboarding ends
    func didAnimationEnd()

    /// Called when the stroke changed
    /// - Parameter percentage: the stroke percentage (between 0 and 1)
    func didStrokeChange(percentage: CGFloat)
}

/// Constants for the stroke selector
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
}

/// Controller for handling the stroke selector on the drawing menu.
final class StrokeSelectorController: UIViewController, StrokeSelectorViewDelegate {
    
    weak var delegate: StrokeSelectorControllerDelegate?
    var sizePercent: CGFloat = 0
    var strokeSize: CGFloat {
        return sizePercent / 100.0
    }

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
    
    /// Shows the animation for onboarding
    func showAnimation() {
        strokeSelectorView.showAnimation()
    }
    
    /// Changes the color of the circle inside the main button and the selector
    ///
    /// - Parameter color: the color to be applied
    func tintStrokeCircle(color: UIColor) {
        strokeSelectorView.tintStrokeCircle(color: color)
    }
    
    /// Calculates the stroke size based on the size selected
    /// on the selector and the min and max values of the texture
    ///
    /// - Parameter minimum: smallest stroke size of the texture
    /// - Parameter maximum: biggest stroke size of the texture
    /// - Returns: stroke size
    func getStrokeSize(minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        let maxIncrement = (maximum / minimum) - 1
        let scale = 1.0 + maxIncrement * sizePercent / 100.0
        return minimum * scale
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
            strokeSelectorView.showSelectorBackground(true)
        case .changed:
            selectorPanned(recognizer: recognizer)
        case .ended, .cancelled, .failed:
            strokeSelectorView.showSelectorBackground(false)
            delegate?.didStrokeChange(percentage: strokeSize)
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Private utilities
    
    private func selectorPanned(recognizer: UILongPressGestureRecognizer) {
        let point = getSelectedLocation(with: recognizer, in: strokeSelectorView.selectorPannableArea)
        strokeSelectorView.moveSelectorCircle(to: point)
        let percent = 100.0 - point.y
        setCircleSize(percent: percent)
        setStrokeSize(percent: percent)
    }
    
    /// Gets the position of the user's finger in the selector.
    /// If the finger goes above or below the selector, the returned position
    /// will be the highest or the lowest respectively.
    ///
    /// - Parameter recognizer: the gesture recognizer
    /// - Parameter view: the view that contains the circle
    /// - Returns: location of the user's finger
    private func getSelectedLocation(with recognizer: UILongPressGestureRecognizer, in view: UIView) -> CGPoint {
        let x = StrokeSelectorView.selectorWidth / 2
        let touchedY = recognizer.location(in: view).y
        let pannableRange = 0...StrokeSelectorView.selectorPannableAreaHeight
        let y = pannableRange.clamp(touchedY)
        
        return CGPoint(x: x, y: y)
    }
    
    /// Changes the stroke circle size according to a percent that goes from
    /// the minimum size (0) to the maximum size (100)
    ///
    /// - Parameter percent: the new size of the circle
    private func setCircleSize(percent: CGFloat) {
        let maxIncrement = (StrokeSelectorView.circleMaxSize / StrokeSelectorView.circleMinSize) - 1
        let scale = 1.0 + maxIncrement * percent / 100.0
        strokeSelectorView.transformCircle(CGAffineTransform(scaleX: scale, y: scale))
    }
    
    private func setStrokeSize(percent: CGFloat) {
        sizePercent = percent
    }
}
