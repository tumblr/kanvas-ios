//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// An option in this collection can be one of 2 kinds
/// and so behave in one of 2 ways
///
/// - twoOptionsImage: Is an option that has only two values (two images)
///     and so it will change from one to the other when it's tapped
/// - twoOptionAnimation: An option that has two values, but only one image. It contains a custom animation.
enum OptionType<Item> {
    case twoOptionsImages(alternateOption: Item, alternateImage: UIImage?)
    case twoOptionsAnimation(animation: (UIView) -> (), duration: TimeInterval, completion: ((UIView) -> ())?)
}

/// A wrapper for Options
final class Option<Item> {
    var option: Item
    var image: UIImage?
    var type: OptionType<Item>

    init(option: Item, image: UIImage?, type: OptionType<Item>) {
        self.option = option
        self.image = image
        self.type = type
    }
}

/// A protocol for handling selecting options
protocol OptionsControllerDelegate: class {
    associatedtype OptionsItem

    /// callback for selecting an option
    func optionSelected(_ item: OptionsItem)
}

/// A class for laying out option buttons and handling tap callbacks
final class OptionsController<Delegate: OptionsControllerDelegate>: UIViewController {

    typealias Item = Delegate.OptionsItem

    private lazy var _view: OptionsStackView<Item> = {
        let view = OptionsStackView(options: options, interItemSpacing: self.spacing)
        view.delegate = self
        return view
    }()
    private let options: [Option<Item>]
    private let spacing: CGFloat

    weak var delegate: Delegate?

    init(options: [Option<Item>], spacing: CGFloat) {
        self.options = options
        self.spacing = spacing
        super.init(nibName: .none, bundle: .none)
    }

    @available(*, unavailable, message: "use init(options:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = _view
    }
    
}

extension OptionsController: OptionsStackViewDelegate {

    func optionWasTapped(optionIndex: Int) {
        let item = options[optionIndex]
        switch item.type {
        case .twoOptionsImages(alternateOption: let otherOption, alternateImage: let otherImage):
            alternateOption(index: optionIndex, newOption: otherOption, newImage: otherImage)
        case .twoOptionsAnimation(animation: let animation, duration: let duration, completion: let completion):
            animateOption(index: optionIndex, duration: duration, animation: animation, completion: completion)
        }
        _view.changeOptions(to: options)
        delegate?.optionSelected(options[optionIndex].option)
    }

    private func alternateOption(index: Int, newOption: Item, newImage: UIImage?) {
        let item = options[index]
        let oldOption = item.option
        let oldImage = item.image
        item.option = newOption
        item.image = newImage
        item.type = .twoOptionsImages(alternateOption: oldOption, alternateImage: oldImage)
    }

    private func animateOption(index: Int, duration: TimeInterval, animation: @escaping (UIView) -> (), completion: ((UIView) -> ())?) {
        UIView.animate(withDuration: duration, animations: {
            animation(self._view.stackView.arrangedSubviews[index])
        }, completion: { _ in
            completion?(self._view.stackView.arrangedSubviews[index])
        })
    }

}
