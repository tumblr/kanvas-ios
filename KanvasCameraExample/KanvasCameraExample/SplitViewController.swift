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

    private var preferences: [String: Bool] = [:]

    private let kanvasSettings: CameraSettings

    private lazy var kanvasNavigationController: UINavigationController = {
        let kanvasAnalyticsProvider = KanvasCameraAnalyticsStub()
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
        preferences["kanvasWelcomeTooltipDismissed"] = true
    }

    func cameraShouldShowWelcomeTooltip() -> Bool {
        return preferences["kanvasWelcomeTooltipDismissed"] != true
    }

    func provideMediaPickerThumbnail(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        completion(nil)
    }
}