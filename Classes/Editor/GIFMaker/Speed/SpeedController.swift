//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for the speed controller
protocol SpeedControllerDelegate: AnyObject {
    
    /// Called when a new speed is selected.
    ///
    /// - Parameter speed: the selected speed.
    func didSelectSpeed(_ speed: Float)
}

/// Constants for SpeedController
private struct Constants {
    static let sliderValues: [Float] = [0.5, 1, 1.5, 2, 3, 4]
    static let sliderInitialIndex: Int = 1
}

/// A view controller that contains the speed tools menu
final class SpeedController: UIViewController, DiscreteSliderDelegate {
    
    weak var delegate: SpeedControllerDelegate?
    private lazy var speedView: SpeedView = SpeedView()
    
    private lazy var speedSlider: DiscreteSlider = {
        let controller = DiscreteSlider(items: Constants.sliderValues, initialIndex: Constants.sliderInitialIndex)
        controller.delegate = self
        return controller
    }()
    
    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesSignificantDigits = true
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: .none, bundle: .none)
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func loadView() {
        view = speedView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        load(childViewController: speedSlider, into: speedView.sliderContainer)
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        speedView.alpha = 0
        
        let initialSpeed = Constants.sliderValues[Constants.sliderInitialIndex]
        setLabelText(initialSpeed)
    }
    
    // MARK: - DiscreteSliderDelegate
    
    func didSelect(item: Float) {
        setLabelText(item)
        delegate?.didSelectSpeed(item)
    }
    
    // MARK: - Private utilities
    
    /// Sets a new formatted text in the label
    ///
    /// - Parameter speed: the new speed value
    private func setLabelText(_ speed: Float) {
        guard let speedText = numberFormatter.string(from: NSNumber(value: speed)) else { return }
        speedView.setLabelText("\(speedText)x")
    }
    
    // MARK: - Public interface
    
    /// shows or hides the speed tools menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        speedView.showView(show)
    }

    func select(speed: Float) {
        speedSlider.select(item: speed)
        setLabelText(speed)
    }
    
}
