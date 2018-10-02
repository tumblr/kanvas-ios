//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct OptionsStackViewConstants {
    static let OptionsChangeAnimationDuration: TimeInterval = 0.2
    static let inset: CGFloat = -10
}

protocol OptionsStackViewDelegate: class {
    /// callback for an option button being tapped
    func optionWasTapped(optionIndex: Int)
}

/// A view for laying out option views in a stack
final class OptionsStackView<Item>: UIView {

    private(set) var stackView: UIStackView
    weak var delegate: OptionsStackViewDelegate?

    private let interItemSpacing: CGFloat

    init(options: [Option<Item>], interItemSpacing: CGFloat) {
        stackView = UIStackView()
        self.interItemSpacing = interItemSpacing
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
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = bounds
        let inset = OptionsStackViewConstants.inset
        let hitTestEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }

    @objc func optionTapped(_ sender: UIButton) {
        delegate?.optionWasTapped(optionIndex: sender.tag)
    }

    /// Update the UI to the new options with an animation
    ///
    /// - Parameter newOptions: an array of the new options to replace the old options
    func changeOptions(to newOptions: [Option<Item>]) {
        let oldStack = stackView
        let newStack = UIStackView()
        stackView = newStack
        setUpStackView(newOptions)
        UIView.animate(withDuration: OptionsStackViewConstants.OptionsChangeAnimationDuration, animations: {
            self.addStackView(newStack)
            oldStack.alpha = 0
        }, completion: { _ in oldStack.removeFromSuperview() })
    }

    // MARK: - private functions

    private func addStackView(_ stackView: UIStackView) {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
        ])
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
            let optionView = OptionView(image: option.image)
            optionView.tag = index
            optionView.accessibilityIdentifier = "Options Option View #\(index + 1)"
            optionView.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(optionView)
        }
    }

}
