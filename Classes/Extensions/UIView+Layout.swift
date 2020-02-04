//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

/**
 This is an extension to properly configure a view according to iOS 11 safe layouts
 If the safe layout is not available, then return a regular layout guide
 */
extension UIView {
    
    var safeLayoutGuide: UILayoutGuide {
        let id = "\(accessibilityIdentifier ?? "").safe_layout"
        
        if let safeGuide = layoutGuides.filter({ $0.identifier == id }).first {
            return safeGuide
        }
        else {
            let safeGuide = UILayoutGuide()
            safeGuide.identifier = id
            addLayoutGuide(safeGuide)
            
            NSLayoutConstraint.activate([
                safeGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                safeGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                safeGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                safeGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            ])
            
            return safeGuide
        }
    }
}

/**
 Represents the possible positions where you can add a view into another.
 */
enum ViewPositioning {
    case back
    case front
}

private struct KanvasViewConstants {
    static let animationDuration: TimeInterval = 0.2
}

extension UIView {
    
    /**
     Loads the view into the specified containerView.
     
     - parameter containerView: The container view.
     - parameter insets: Insets that separate self from the container view. By default, .zero.
     - parameter viewPositioning: Back or Front. By default, .front.
     - parameter useConstraints: Boolean indicating whether to use constraints or frames. By default, true.
     
     - note: If you decide to use constraints to determine the size, the container's frame doesn't need to be final.
     Because of this, it can be used in `loadView()`, `viewDidLoad()` or `viewWillAppear(animated:)`.
     We strongly recommend to work with constraints as a better practice than frames.
     Also, this function matches left inset to leading and right to trailing of the view.
     */
    func add(into containerView: UIView,
             with insets: UIEdgeInsets = .zero,
             in viewPositioning: ViewPositioning = .front,
             respectSafeArea: Bool = false,
             useConstraints: Bool = true) {
        if useConstraints {
            containerView.addSubview(self)
            
            translatesAutoresizingMaskIntoConstraints = false
            addConstraints(containerView: containerView, insets: insets, respectSafeArea: respectSafeArea)
        }
        else {
            let bounds = respectSafeArea ? containerView.safeLayoutGuide.layoutFrame : containerView.bounds
            let x = insets.left
            let y = insets.top
            let width = bounds.width - x - insets.right
            let height = bounds.height - y - insets.bottom
            frame = CGRect(x: x, y: y, width: width, height: height)
            
            containerView.addSubview(self)
        }
        
        if case viewPositioning = ViewPositioning.back {
            containerView.sendSubviewToBack(self)
        }
    }
    
    private func addConstraints(containerView: UIView, insets: UIEdgeInsets, respectSafeArea: Bool) {
        if respectSafeArea {
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: containerView.safeLayoutGuide.topAnchor, constant: insets.top),
                containerView.safeLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
                leadingAnchor.constraint(equalTo: containerView.safeLayoutGuide.leadingAnchor, constant: insets.left),
                containerView.safeLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right)
                ])
        }
        else {
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: containerView.topAnchor, constant: insets.top),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
                leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: insets.left),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right)
                ])
        }
    }
    
    /**
     Sets the alpha for subviews
     - parameter shownViews: subviews to show
     - parameter hiddenViews: subviews to hide
     - parameter animated: whether to animate the alpha values
     - parameter animationDuration: the duration in seconds to show the animation
     */
    internal func showViews(shownViews: [UIView?],
                            hiddenViews: [UIView?],
                            animated: Bool = false,
                            animationDuration: TimeInterval = KanvasViewConstants.animationDuration) {
        let duration = animated ? animationDuration : 0
        for view in (shownViews + hiddenViews) {
            view?.isUserInteractionEnabled = false
        }
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            for view in shownViews {
                view?.alpha = 1
            }
            for view in hiddenViews {
                view?.alpha = 0
            }
        }, completion: { (finished: Bool) in
            for view in (shownViews + hiddenViews) {
                view?.isUserInteractionEnabled = true
            }
        })
    }
}
