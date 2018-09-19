//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

private struct ModalPresentationControllerConstants {
    static let Margin: CGFloat = 24
    static let MaximumWidth: CGFloat = 350.0
    static let MaximumPriority = UILayoutPriority(999)
    static let LessPriority = UILayoutPriority(975)
    static let BackgroundViewColor: UIColor = UIColor.black.withAlphaComponent(0.8)
}

/// A class to handle the presentation logic for the modal
final class ModalPresentationController: UIPresentationController {

    private lazy var dimmingView: UIView = {
        guard let containerView = containerView else { return UIView() }
        let view = UIView(frame: containerView.bounds)
        view.backgroundColor = ModalPresentationControllerConstants.BackgroundViewColor
        return view
    }()

    typealias AnimationBlock = (_ context: UIViewControllerTransitionCoordinatorContext?) -> Void

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return containerView.bounds.insetBy(dx: 50.0, dy: 50.0)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let presentedView = presentedView else { return }
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0.0
        dimmingView.add(into: containerView)

        containerView.addSubview(presentedView)
        presentedView.translatesAutoresizingMaskIntoConstraints = false
        setConstraints()

        let transitionCoordinator = presentingViewController.transitionCoordinator
        let decreaseDimmingViewTransparency: AnimationBlock = { [unowned self] _ in
            self.dimmingView.alpha  = 1.0
        }
        transitionCoordinator?.animate(alongsideTransition: decreaseDimmingViewTransparency, completion: .none)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed { dimmingView.removeFromSuperview() }
    }

    override func viewWillTransition(to size: CGSize,
                                            with transitionCoordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: transitionCoordinator)
        let setDimmingViewFrame: AnimationBlock = { [unowned self] _ in
            guard let containerView = self.containerView else { return }
            self.dimmingView.frame = containerView.bounds
        }
        transitionCoordinator.animate(alongsideTransition: setDimmingViewFrame, completion: .none)
    }

    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator
        let increaseDimmingViewTransparency: AnimationBlock = { [unowned self] _ in
            self.dimmingView.alpha  = 0.0
        }
        transitionCoordinator?.animate(alongsideTransition: increaseDimmingViewTransparency, completion: .none)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed { dimmingView.removeFromSuperview() }
    }
    
    // MARK: - private

    private func setConstraints() {
        guard let containerView = containerView, let presentedView = presentedView else { return }

        let widthConstraint = presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: ModalPresentationControllerConstants.MaximumWidth)
        widthConstraint.priority = ModalPresentationControllerConstants.MaximumPriority
        let leadingConstraint = presentedView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor,
                                                                       constant: ModalPresentationControllerConstants.Margin)
        leadingConstraint.priority = ModalPresentationControllerConstants.LessPriority
        let trailingConstraint = presentedView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor,
                                                                         constant: -ModalPresentationControllerConstants.Margin)
        trailingConstraint.priority = ModalPresentationControllerConstants.LessPriority

        NSLayoutConstraint.activate([
            presentedView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            presentedView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            widthConstraint,
            leadingConstraint,
            trailingConstraint
        ])
    }

}
