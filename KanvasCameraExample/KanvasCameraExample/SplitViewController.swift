//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import KanvasCamera
import TumblrTheme

@objc protocol DashboardPagingController: class {
    func setPageSlideEnabled(_ pageSlideEnabled: Bool)

    /// Navigates to the Kanvas view controller.
    func navigateToKanvas()
}


@objc final class SplitViewController: UISplitViewController {

    private let isKanvasHorizontalSwipingEnabled: Bool = true

    private var pageViewController: TMPageViewController?

    private lazy var kanvasNavigationController: UINavigationController = {
        let kanvasAnalyticsProvider = KanvasCameraAnalyticsStub()

        let kanvasSettings = CameraSettings()
        kanvasSettings.features.ghostFrame = true
        kanvasSettings.features.openGLPreview = true
        kanvasSettings.features.openGLCapture = true
        kanvasSettings.features.cameraFilters = true
        kanvasSettings.features.experimentalCameraFilters = true
        kanvasSettings.features.editor = true
        kanvasSettings.features.editorFilters = true
        kanvasSettings.features.editorMedia = true
        kanvasSettings.features.editorDrawing = true
        kanvasSettings.features.mediaPicking = true
        kanvasSettings.enabledModes = [.stopMotion, .photo, .gif]
        kanvasSettings.defaultMode = .stopMotion

        let kanvasViewController = CameraController(settings: kanvasSettings, analyticsProvider: kanvasAnalyticsProvider)
        kanvasViewController.delegate = self

        let kanvasNavigationController = UINavigationController(navigationBarClass: nil, toolbarClass: nil)
        kanvasNavigationController.viewControllers = [kanvasViewController]
        kanvasNavigationController.delegate = self
        kanvasNavigationController.isNavigationBarHidden = true
        return kanvasNavigationController
    }()

    /// The internal tab bar controller. On iPad, the tabs are hidden.
    @objc lazy var tumblrTabBarController: UIViewController = {
        let tabBarController = MockDashboardViewController(nibName: nil, bundle: nil)
        tabBarController.delegate = self
        let tumblrNavigationController = UINavigationController(navigationBarClass: nil, toolbarClass: nil)
        tumblrNavigationController.delegate = self
        //tumblrNavigationController.isNavigationBarHidden = true
        tumblrNavigationController.viewControllers = [tabBarController]
        return tumblrNavigationController
    }()

    // MARK: - Initializers

    /// Designated initializer.
    @objc init() {

        super.init(nibName: nil, bundle: nil)

        var orderedViewControllers: [UIViewController] = [tumblrTabBarController]
        if isKanvasHorizontalSwipingEnabled {
            orderedViewControllers.insert(kanvasNavigationController, at: 0)
        }
        let pageViewController = TMPageViewController(orderedViewControllers: orderedViewControllers,
                                                      initialViewController: tumblrTabBarController,
                                                      delegate: nil)
        pageViewController.pagingEnabled = true
        self.pageViewController = pageViewController
        self.viewControllers = [pageViewController]
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        assertionFailure("init(coder:) not supported")
        return nil
    }

}

// MARK: - TMNavigationControllerDelegate
extension SplitViewController: UINavigationControllerDelegate {

    func navigationControllerWillShow(_ viewController: UIViewController) {
        /// SwipeableDash is only available when the rootViewController on the page is the top viewController.
        guard let pageViewController = pageViewController else { return }
        guard let rootViewController = viewController.navigationController?.viewControllers.first else { return }
        pageViewController.pagingEnabled = (rootViewController === viewController)
    }

    func navigationControllerDidShow(_ viewController: UIViewController) {
        // no-op
    }

}

// MARK: - DashboardPagingController
extension SplitViewController: DashboardPagingController {

    func setPageSlideEnabled(_ pageSlideEnabled: Bool) {
        pageViewController?.pagingEnabled = pageSlideEnabled
    }

    func navigateToKanvas() {
        pageViewController?.moveToViewController(kanvasNavigationController, animated: true, direction: .reverse)
    }

    @objc func navigateFromKanvas() {
        pageViewController?.moveToViewController(tumblrTabBarController, animated: true, direction: .forward)
    }

}

extension SplitViewController: MockDashboardViewControllerDelegate {
    func kanvasButtonTapped() {
        navigateToKanvas()
    }
}

extension SplitViewController: CameraControllerDelegate {
    func didCreateMedia(media: KanvasCameraMedia?, error: Error?) {
        assertionFailure("didCreateMedia not implemented")
    }

    func dismissButtonPressed() {
        navigateFromKanvas()
    }

    func didDismissWelcomeTooltip() {
        // ???
    }

    func cameraShouldShowWelcomeTooltip() -> Bool {
        // ugh
        return true
    }

    func provideMediaPickerThumbnail(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        completion(nil)
    }
}

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
        return currentViewController
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

        let oldViewController = currentViewController
        self.pagingDelegate?.pageWillBecomeVisible(viewController)

        let changeCurrentViewController = { [weak self] (incomingViewController: UIViewController) in
            self?.currentViewController = incomingViewController
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
        pagingDelegate?.pageWillBecomeVisible(incomingViewController)
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
            pagingDelegate?.pageGainedFocus(currentViewController)
        }
    }
}
