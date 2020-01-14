//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import KanvasCamera
import TumblrTheme
import Photos
import SharedUI

@objc protocol DashboardPagingController: class {
    func setPageSlideEnabled(_ pageSlideEnabled: Bool)

    /// Navigates to the Kanvas view controller.
    func navigateToKanvas()
}


@objc final class SplitViewController: UISplitViewController {

    private let isKanvasHorizontalSwipingEnabled: Bool = true

    private var pageViewController: TMPageViewController?

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

    // MARK: - Initializers

    /// Designated initializer.
    @objc init(settings: CameraSettings) {
        kanvasSettings = settings

        super.init(nibName: nil, bundle: nil)

        var orderedViewControllers: [UIViewController] = [tumblrTabBarController]
        if isKanvasHorizontalSwipingEnabled {
            orderedViewControllers.insert(kanvasController, at: 0)
        }
        let pageViewController = TMPageViewController(orderedViewControllers: orderedViewControllers,
                                                      initialViewController: tumblrTabBarController,
                                                      delegate: self)
        pageViewController.pagingEnabled = true
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
        openedKanvasWithTap = true
        pageViewController?.moveToViewController(kanvasController, animated: true, direction: .reverse)
    }

    @objc func navigateFromKanvas() {
        closedKanvasWithTap = true
        pageViewController?.moveToViewController(tumblrTabBarController, animated: true, direction: .forward)
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
    var kanvasDashboardAnalyticsProvider: KanvasCameraAnalyticsProvider {
        return KanvasCameraAnalyticsStub()
    }

    var kanvasDashboardBlogUUID: String? {
        return nil
    }

    var kanvasDashboardUnloadStrategy: KanvasDashboardController.UnloadStrategy {
        return .never
    }
}

extension SplitViewController: TMPageViewControllerDelegate {
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
