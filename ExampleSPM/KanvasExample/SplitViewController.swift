//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Kanvas
import Photos
import UIKit

@objc protocol DashboardPagingController: AnyObject {
    func setPageSlideEnabled(_ pageSlideEnabled: Bool)

    /// Navigates to the Kanvas view controller.
    func navigateToKanvas()
}


@objc final class SplitViewController: UISplitViewController {

    private let isKanvasHorizontalSwipingEnabled: Bool = true

    private var pageViewController: UIPageViewController?

    private var preferences: [String: Bool] = [:]

    private let kanvasSettings: CameraSettings

    private var openedKanvasWithTap: Bool = false
    private var closedKanvasWithTap: Bool = false

    private lazy var kanvasController: KanvasDashboardController = {
        let kanvasDashboardController = KanvasDashboardController(settings: kanvasSettings)
        kanvasDashboardController.delegate = self
        kanvasDashboardController.stateDelegate = self
        return kanvasDashboardController
    }()

    /// The internal tab bar controller. On iPad, the tabs are hidden.
    @objc lazy var tumblrTabBarController: UIViewController = {
        let tabBarController = MockDashboardViewController(nibName: nil, bundle: nil)
        tabBarController.delegate = self
        tabBarController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let tumblrNavigationController = UINavigationController(navigationBarClass: nil, toolbarClass: nil)
        tumblrNavigationController.delegate = self
        tumblrNavigationController.viewControllers = [tabBarController]
        return tumblrNavigationController
    }()

    @objc func doneButtonTapped() {
        dismiss(animated: true, completion: .none)
    }
    
    fileprivate var orderedViewControllers: [UIViewController] = []

    // MARK: - Initializers

    /// Designated initializer.
    @objc init(settings: CameraSettings) {
        kanvasSettings = settings

        super.init(nibName: nil, bundle: nil)

        var orderedViewControllers: [UIViewController] = [tumblrTabBarController]
        if isKanvasHorizontalSwipingEnabled {
            orderedViewControllers.insert(kanvasController, at: 0)
        }
        self.orderedViewControllers = orderedViewControllers
        
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        if let first = orderedViewControllers.first {
            pageViewController.setViewControllers([first], direction: .forward, animated: false, completion: nil)
        }
        self.pageViewController = pageViewController
        self.viewControllers = [pageViewController]
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        assertionFailure("init(coder:) not supported")
        return nil
    }

    override var childForStatusBarHidden: UIViewController? {
        return pageViewController
    }

    override var childForStatusBarStyle: UIViewController? {
        return pageViewController
    }

}

// MARK: - TMNavigationControllerDelegate
extension SplitViewController: UINavigationControllerDelegate {

    func navigationControllerWillShow(_ viewController: UIViewController) {
        /// SwipeableDash is only available when the rootViewController on the page is the top viewController.
        guard let pageViewController = pageViewController else { return }
        guard let rootViewController = viewController.navigationController?.viewControllers.first else { return }
        pageViewController.gestureRecognizers.forEach { recognizer in
            recognizer.isEnabled = (rootViewController === viewController)
        }
    }

    func navigationControllerDidShow(_ viewController: UIViewController) {
        // no-op
    }

}

// MARK: - DashboardPagingController
extension SplitViewController: DashboardPagingController {

    func setPageSlideEnabled(_ pageSlideEnabled: Bool) {
        pageViewController?.gestureRecognizers.forEach { recognizer in
            recognizer.isEnabled = pageSlideEnabled
        }
    }

    func navigateToKanvas() {
        openedKanvasWithTap = true
        pageViewController?.setViewControllers([kanvasController], direction: .reverse, animated: true, completion: nil)
    }

    @objc func navigateFromKanvas() {
        closedKanvasWithTap = true
        pageViewController?.setViewControllers([tumblrTabBarController], direction: .forward, animated: true, completion: nil)
    }

}

extension SplitViewController: MockDashboardViewControllerDelegate {
    func kanvasButtonTapped() {
        navigateToKanvas()
    }
}

extension SplitViewController: KanvasDashboardControllerDelegate {
    func kanvasDashboardOpenPostingOptionsRequest() {
        navigateFromKanvas()
    }
    
    func kanvasDashboardConfirmPostingOptionsRequest() {
        navigateFromKanvas()
    }

    func kanvasDashboardOpenComposeRequest() {
        navigateFromKanvas()
    }

    func kanvasDashboardCreatePostRequest() {
        navigateFromKanvas()
    }

    func kanvasDashboardDismissRequest() {
        navigateFromKanvas()
    }

    func kanvasDashboardNeedsAccount() {

    }
}

extension SplitViewController: KanvasDashboardStateDelegate {
    var kanvasDashboardAnalyticsProvider: KanvasAnalyticsProvider {
        return KanvasAnalyticsStub()
    }

    var kanvasDashboardUnloadStrategy: KanvasDashboardController.UnloadStrategy {
        return .never
    }
}

extension SplitViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = orderedViewControllers.firstIndex(of: viewController) {
            let nextIndex = orderedViewControllers.index(before: index)
            if orderedViewControllers.startIndex <= nextIndex {
                let nextVC = orderedViewControllers[nextIndex]
                return nextVC
            }
            return nil
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = orderedViewControllers.firstIndex(of: viewController) {
            let nextIndex = orderedViewControllers.index(after: index)
            if orderedViewControllers.indices.contains(nextIndex) {
                let nextVC = orderedViewControllers[nextIndex]
                return nextVC
            }
            return nil
        }
        return nil
    }
    
    
}

extension SplitViewController: UIPageViewControllerDelegate {
    func canMoveToViewController(_ viewController: UIViewController) -> Bool {
        return true
    }
    
    func pageWillBecomeVisible(_ viewController: UIViewController) {
        if viewController == kanvasController {
            kanvasController.pageWillBecomeVisible(tapped: openedKanvasWithTap)
        }
    }

    func pageDidBecomeHidden(_ viewController: UIViewController) {
        if viewController == kanvasController {
            kanvasController.pageDidBecomeHidden(tapped: closedKanvasWithTap)
            closedKanvasWithTap = false
        }
    }

    func pageGainedFocus(_ viewController: UIViewController) {
        if viewController == kanvasController {
            kanvasController.pageGainedFocus(tapped: openedKanvasWithTap)
            openedKanvasWithTap = false
        }
    }
}
