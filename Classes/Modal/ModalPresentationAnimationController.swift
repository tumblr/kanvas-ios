//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

private struct ModalPresentationAnimationConstants {
    static let duration: TimeInterval = 0.5
}

/// An class conforming to UIViewControllerAnimatedTransitioning to handle presentation
final class ModalPresentationAnimationController: NSObject {

    private let isPresenting: Bool

    /// initializer that defaults the presentingState
    ///
    /// - Parameter isPresenting: whether the controller should be presenting
    public init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }

    // MARK: - private
    private func animatePresentation(with transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)
            else { return }
        
        let containerView = transitionContext.containerView
        presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
        presentedControllerView.center.y -= containerView.bounds.size.height
        
        containerView.addSubview(presentedControllerView)
        animateView(presentedControllerView, containerView: containerView, transitionContext: transitionContext)
    }
    
    private func animateDismissal(with transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedControllerView = transitionContext.view(forKey: .from) else { return }
        let containerView = transitionContext.containerView
        animateView(presentedControllerView, containerView: containerView, transitionContext: transitionContext)
    }
    
    private func animateView(_ presentedControllerView: UIView,
                             containerView: UIView,
                             transitionContext: UIViewControllerContextTransitioning) {
        let completedBlock: (_ completed: Bool) -> Void = {
            transitionContext.completeTransition($0)
        }
        UIView.animate(withDuration: ModalPresentationAnimationConstants.duration,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: .allowUserInteraction,
                       animations: { presentedControllerView.center.y += containerView.bounds.size.height },
                       completion: completedBlock)
        
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension ModalPresentationAnimationController: UIViewControllerAnimatedTransitioning {

    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return ModalPresentationAnimationConstants.duration
    }

    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentation(with: transitionContext)
        }
        else {
            animateDismissal(with: transitionContext)
        }
    }

}
