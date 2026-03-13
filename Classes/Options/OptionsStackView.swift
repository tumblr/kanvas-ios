//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct OptionsStackViewConstants {
    static let optionsChangeAnimationDuration: TimeInterval = 0.2
    static let inset: CGFloat = -15
}

protocol OptionsStackViewDelegate: AnyObject {
    /// callback for an option button being tapped
    func optionWasTapped(section: Int, optionIndex: Int)
}

/// A view for laying out option views in a stack
final class OptionsStackView<Item>: IgnoreTouchesView {

    /// The stackView is an ExtendedStackView to allow for touch events beyond it's regular bounds.
    /// This is to allow for smaller frames for buttons in a stack view but still have them register touches correctly
    private(set) var stackView: ExtendedStackView
    weak var delegate: OptionsStackViewDelegate?

    private let section: Int
    private let interItemSpacing: CGFloat
    private let settings: CameraSettings

    /// Creates a view containing a horizontal StackView with options
    ///
    /// - Parameters:
    ///   - section: number that represents the view in case there are multiple OptionStackViews
    ///     calling methods on the same delegate.
    ///   - options: settings that will be displayed horizontally in the StackView
    ///   - interItemSpacing: horizontal spacing between the StackView buttons
    ///   - settings: camera settings
    init(section: Int, options: [Option<Item>], interItemSpacing: CGFloat, settings: CameraSettings) {
        stackView = ExtendedStackView(inset: OptionsStackViewConstants.inset)
        self.section = section
        self.interItemSpacing = interItemSpacing
        self.settings = settings
        super.init(frame: .zero)

        setUpStackView(options)
        addStackView(stackView)
        stackView.alpha = 1
    }

    @available(*, unavailable, message: "use init(options:) instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(options:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func optionTapped(_ sender: UIButton) {
        delegate?.optionWasTapped(section: section, optionIndex: sender.tag)
    }

    /// This overridden function returns whether the point for any given event is inside this button's frame
    /// It adds the inset values to the frame, so a negative inset would create an `outset`, and a larger tappable area
    ///
    /// - Parameters:
    ///   - point: The point to test
    ///   - event: UIEvent
    /// - Returns: Bool for whether the point should be recognized by this view
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = bounds
        let inset = OptionsStackViewConstants.inset
        let hitTestEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
    
    /// Update the UI to the new options with an animation
    ///
    /// - Parameter newOptions: an array of the new options to replace the old options
    func changeOptions(to newOptions: [Option<Item>]) {
        let oldStack = stackView
        let newStack = ExtendedStackView(inset: OptionsStackViewConstants.inset)
        stackView = newStack
        setUpStackView(newOptions)
        let animation: () -> Void = {
            self.addStackView(newStack)
            oldStack.alpha = 0
        }
        
        let completion: (Bool) -> Void = { _ in
            oldStack.removeFromSuperview()
        }
        
        if KanvasDesign.shared.isBottomPicker {
            animation()
            completion(true)
        }
        else {
            UIView.animate(withDuration: OptionsStackViewConstants.optionsChangeAnimationDuration, animations: animation, completion: completion)
        }
    }

    // MARK: - private functions

    private func addStackView(_ stackView: UIStackView) {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        if settings.topButtonsSwapped {
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
            ])
        }
        else {
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
    }

    private func setUpStackView(_ options: [Option<Item>]) {
        stackView.accessibilityIdentifier = "Options StackView"
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = interItemSpacing
        addOptions(options)
    }

    private func addOptions(_ options: [Option<Item>]) {
        options.enumerated().forEach { (index, option) in
            let optionView = OptionView(image: option.image, inset: OptionsStackViewConstants.inset,
                                        backgroundColor: option.backgroundColor)
            optionView.button.tag = index
            optionView.accessibilityIdentifier = "Options Option View #\(index + 1)"
            optionView.button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            NSLayoutConstraint.activate([
                optionView.heightAnchor.constraint(equalToConstant: CameraConstants.optionButtonSize),
                optionView.widthAnchor.constraint(equalToConstant: CameraConstants.optionButtonSize)
            ])
            stackView.addArrangedSubview(optionView)
        }
    }

}
