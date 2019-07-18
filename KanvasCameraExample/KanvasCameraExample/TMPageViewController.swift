//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

/// TMPageViewControllerDelegate - receiver of helpful events from a TMPageViewController
@objc protocol TMPageViewControllerDelegate: class {
    /// a page will become at least partially visible in a sliding animation
    func pageWillBecomeVisible(_ viewController: UIViewController)
    /// a page become completely hidden after a sliding animation
    func pageDidBecomeHidden(_ viewController: UIViewController)
    /// a page became completely visible after a sliding animation
    func pageGainedFocus(_ viewController: UIViewController)
}

/**
 TMPageViewController - a view controller for managing a paging experience for a finite set of full screen view controllers.
 Unlike its superclass, TMPageViewController does _not_ support presenting multiple view controllers concurrently, and instead can guarantee the identity of current view controller in focus.
 TMPageViewController is a self contained dataSource and delegate for its superclass's functionality, and proxies helpful events out via its pagingDelegate property
 */
final class TMPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    @objc var pagingEnabled: Bool {
        get {
            return innerScrollView?.isScrollEnabled ?? false
        }
        set {
            if let innerScrollView = innerScrollView {
                return innerScrollView.isScrollEnabled = newValue
            }
        }
    }

    /// allow bouncing and overscrolling
    @objc var bounceEnabled: Bool = true

    /// The view controller currently in focus
    @objc private (set) var currentViewController: UIViewController

    /// The view controller that is potentially incoming
    private var incomingViewController: UIViewController?

    /// The navigation controller currently in focus
    @objc public var currentNavigationController: UINavigationController? {
        if let navigationController = currentViewController as? UINavigationController {
            return navigationController
        }
        return nil
    }

    /// All view controllers, in their paging order
    private let orderedViewControllers: [UIViewController]

    private lazy var innerScrollView: UIScrollView? = {
        var scrollView: UIScrollView? = nil
        for view in view.subviews {
            if let view = view as? UIScrollView {
                if scrollView != nil {
                    assertionFailure("More than one UIScrollView found, can not guarantee which to use")
                }
                scrollView = view
            }
        }
        if scrollView == nil {
            assertionFailure("inner UIScrollView could not be found")
        }
        return scrollView
    }()

    /// Delegate for paging events
    private weak var pagingDelegate: TMPageViewControllerDelegate?

    override var childForStatusBarStyle: UIViewController? {
        return incomingViewController ?? currentViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        return incomingViewController ?? currentViewController
    }

    /**
     Init a TMPageViewController with a set of view controllers, with initialViewController appearing first

     - parameter orderedViewControllers: The view controllers which the TMPageViewController may page through, in the order they may be pages through.
     - parameter initialViewController: The first view controller which should be presented by the TMPageViewController. Must be contained by orderedViewControllers.
     - parameter delegate: A TMPageViewControllerDelegate for helpful paging events
     */
    @objc init(orderedViewControllers: [UIViewController], initialViewController: UIViewController, delegate: TMPageViewControllerDelegate?) {
        assert(orderedViewControllers.contains(initialViewController), "Initial view controller must be a within the orderedViewControllers array")

        self.orderedViewControllers = orderedViewControllers
        pagingDelegate = delegate
        currentViewController = initialViewController

        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

        if let scrollView = innerScrollView {
            // also defensively caches the lazy var innerScrollView before clients using TMPageViewController have a chance to modify our view
            scrollView.delegate = self
        }

        self.dataSource = self
        self.delegate = self

        // Don't call moveToViewController so we don't trigger delegate events on init
        super.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Change the view controller in focus, moving the arg `viewController` on screen and moving the current off

     - parameter viewController: The view controller to move. Must be contained by the orderedViewControllers this instance was init'ed with.
     - parameter animated: If moving to this view controller should be animated with a sliding animation
     - parameter direction: Which direction to animate.
     */
    @objc func moveToViewController(_ viewController: UIViewController, animated: Bool, direction: UIPageViewController.NavigationDirection) {
        guard orderedViewControllers.contains(viewController), viewController !== currentViewController else {
            return
        }

        incomingViewController = viewController
        let oldViewController = currentViewController
        self.pagingDelegate?.pageWillBecomeVisible(viewController)
        updateStatusBar(animated: animated)

        let changeCurrentViewController = { [weak self] (incomingViewController: UIViewController) in
            self?.currentViewController = incomingViewController
            self?.incomingViewController = nil
            self?.pagingDelegate?.pageDidBecomeHidden(oldViewController)
            self?.pagingDelegate?.pageGainedFocus(incomingViewController)
        }

        if animated {
            // completion block only fires when animated == true
            super.setViewControllers([viewController], direction: direction, animated: animated, completion: { (_) in
                changeCurrentViewController(viewController)
            })
        }
        else {
            super.setViewControllers([viewController], direction: direction, animated: false)
            changeCurrentViewController(viewController)
        }
    }

    // directly calling setViewControllers will skip our currentViewController and delegate event logic, force clients to use moveToViewController
    @available(*, unavailable, message: "use moveToViewController() instead")
    override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)?) {
        super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
    }

    private func indexFor(viewController: UIViewController) -> Int? {
        return orderedViewControllers.firstIndex(of: viewController)
    }

    //MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // mcornell 1/17/19 - it is kinda possible to still make a bounce happen when bounceEnabled == false if you swipe _really_ hard while you're on the second to last view controller in either direction (ex: going really hard to 0 while at 1 might bounce a little on the left side). I'm leaving this alone because that gesture is hard to pull off and the background color still makes it look natural
        if !bounceEnabled {
            if currentViewController == orderedViewControllers.first && scrollView.contentOffset.x < scrollView.bounds.size.width {
                scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
            }
            else if currentViewController == orderedViewControllers.last && scrollView.contentOffset.x > scrollView.bounds.size.width {
                scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !bounceEnabled {
            if currentViewController == orderedViewControllers.first && scrollView.contentOffset.x <= scrollView.bounds.size.width {
                targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
            }
            else if currentViewController == orderedViewControllers.last && scrollView.contentOffset.x >= scrollView.bounds.size.width {
                targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
            }
        }
    }

    //MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = indexFor(viewController: viewController) else {
            return nil
        }
        if currentIndex > 0 {
            return orderedViewControllers[currentIndex - 1]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = indexFor(viewController: viewController) else {
            return nil
        }
        if currentIndex < orderedViewControllers.count - 1 {
            return orderedViewControllers[currentIndex + 1]
        }
        return nil
    }

    // The moment a user initiated slide to reveal starts - you can probably see some of the incoming vc at this point
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let incomingViewController = pendingViewControllers.first else {
            return
        }
        self.incomingViewController = incomingViewController
        pagingDelegate?.pageWillBecomeVisible(incomingViewController)
        updateStatusBar(animated: true)
    }

    // the moment a user initiated swipe to reveal animation settled on a vc
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // user followed through with slide action
        if completed && finished {
            guard let newCurrentVC = pageViewController.viewControllers?.first else {
                assertionFailure("Incoming view controller should not be nil for completed user-initiated animations")
                return
            }
            pagingDelegate?.pageDidBecomeHidden(currentViewController)
            currentViewController = newCurrentVC
            incomingViewController = nil
            pagingDelegate?.pageGainedFocus(currentViewController)
        }
        // user bailed with the page slide
        if finished && !completed {
            incomingViewController = nil
            updateStatusBar(animated: true)
        }
    }

    private func updateStatusBar(animated: Bool) {
        let update: () -> Void = { [weak self] in
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        if !animated {
            update()
        }
        else {
            UIView.animate(withDuration: 0.2, animations: update)
        }
    }
}
