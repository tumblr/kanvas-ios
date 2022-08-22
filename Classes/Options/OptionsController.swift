//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct OptionsControllerConstants {
    static let rowSpacing: CGFloat = 20
    static let animationDuration = 0.25
    static let imagePreviewRow = 2
}

/// An option in this collection can be one of 2 kinds
/// and so behave in one of 2 ways
///
/// - twoOptionsImage: Is an option that has only two values (two images)
///     and so it will change from one to the other when it's tapped
/// - twoOptionAnimation: An option that has two values, but only one image. It contains a custom animation.
enum OptionType<Item> {
    case twoOptionsImages(alternateOption: Item, alternateImage: UIImage?, alternateBackgroundColor: UIColor)
    case twoOptionsAnimation(animation: (UIView) -> (), duration: TimeInterval, completion: ((UIView) -> ())?)
}

/// A wrapper for Options
final class Option<Item> {
    var option: Item
    var image: UIImage?
    var backgroundColor: UIColor
    var type: OptionType<Item>

    /// The initializer for Options
    ///
    /// - Parameters:
    ///   - option: The generic option that this class will represent
    ///   - image: an optional UIImage to represent it
    ///   - backgroundColor: the background color for the item image
    ///   - type: the OptionType to initalize as
    init(option: Item, image: UIImage?, backgroundColor: UIColor, type: OptionType<Item>) {
        self.option = option
        self.image = image
        self.backgroundColor = backgroundColor
        self.type = type
    }
}

/// A protocol for handling selecting options
protocol OptionsControllerDelegate: AnyObject {
    associatedtype OptionsItem

    /// callback for selecting an option
    func optionSelected(_ item: OptionsItem)
}

/// A class for laying out option buttons and handling tap callbacks
final class OptionsController<Delegate: OptionsControllerDelegate>: UIViewController {

    typealias Item = Delegate.OptionsItem

    private lazy var optionsStackViews: [OptionsStackView<Item>] = {
        var optionViews: [OptionsStackView<Item>] = []
        for index in 0..<options.count {
            let view = OptionsStackView(section: index, options: options[index], interItemSpacing: self.spacing, settings: self.settings)
            view.delegate = self
            optionViews.append(view)
        }
        
        return optionViews
    }()

    private lazy var imagePreviewOptionsStackView: OptionsStackView<Item>? = {
        if OptionsControllerConstants.imagePreviewRow < self.optionsStackViews.count {
            return self.optionsStackViews[OptionsControllerConstants.imagePreviewRow]
        }
        return nil
    }()
    
    private let options: [[Option<Item>]]
    private let spacing: CGFloat
    private let settings: CameraSettings

    weak var delegate: Delegate?

    /// The designated initializer for the OptionsController
    ///
    /// - Parameters:
    ///   - options: the Option items to display in the stack view
    ///   - spacing: the amount of spacing for the internal stack view
    init(options: [[Option<Item>]], spacing: CGFloat, settings: CameraSettings) {
        self.options = options
        self.spacing = spacing
        self.settings = settings
        super.init(nibName: .none, bundle: .none)
    }

    @available(*, unavailable, message: "use init(options:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// This is overridden in order to get the extended tap area from OptionsStackView
    override func loadView() {
        view = createVerticalStackView()
    }
    
    // Creates the stack view that will contain the other two
    private func createVerticalStackView() -> UIStackView {
        let stackView = IgnoreBackgroundTouchesStackView(arrangedSubviews: optionsStackViews)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = CameraConstants.optionSpacing
        return stackView
    }
    
    // MARK: - Public interface
    
    /// Changes the visibility of the top options depending on the clip collection size
    ///
    /// - Parameter areThereClips: whether there are clips or the collection is empty
    func configureOptions(areThereClips: Bool) {
        UIView.animate(withDuration: OptionsControllerConstants.animationDuration) { [weak self] in
            self?.imagePreviewOptionsStackView?.alpha = areThereClips ? 1 : 0
        }
    }

    /// Is the image preview option available?
    func imagePreviewOptionAvailable() -> Bool {
        return self.imagePreviewOptionsStackView?.alpha == 1
    }
}

extension OptionsController: OptionsStackViewDelegate {

    func optionWasTapped(section: Int, optionIndex: Int) {
        let item = options[section][optionIndex]
        switch item.type {
        case .twoOptionsImages(alternateOption: let otherOption, alternateImage: let otherImage, alternateBackgroundColor: let otherBackgroundColor):
            alternateOption(section: section, index: optionIndex, newOption: otherOption, newImage: otherImage, newBackgroundColor: otherBackgroundColor)
        case .twoOptionsAnimation(animation: let animation, duration: let duration, completion: let completion):
            animateOption(section: section, index: optionIndex, duration: duration, animation: animation, completion: completion)
        }
        
        for section in 0..<options.count {
            optionsStackViews[section].changeOptions(to: options[section])
        }
        
        delegate?.optionSelected(options[section][optionIndex].option)
    }

    private func alternateOption(section: Int, index: Int, newOption: Item, newImage: UIImage?, newBackgroundColor: UIColor) {
        let item = options[section][index]
        let oldOption = item.option
        let oldImage = item.image
        let oldBackgroundColor = item.backgroundColor
        item.option = newOption
        item.image = newImage
        item.type = .twoOptionsImages(alternateOption: oldOption, alternateImage: oldImage, alternateBackgroundColor: oldBackgroundColor)
        item.backgroundColor = newBackgroundColor
    }

    private func animateOption(section: Int, index: Int, duration: TimeInterval, animation: @escaping (UIView) -> (), completion: ((UIView) -> ())?) {
        UIView.animate(withDuration: duration, animations: {
            animation(self.optionsStackViews[section].stackView.arrangedSubviews[index])
        }, completion: { _ in
            completion?(self.optionsStackViews[section].stackView.arrangedSubviews[index])
        })
    }

}
