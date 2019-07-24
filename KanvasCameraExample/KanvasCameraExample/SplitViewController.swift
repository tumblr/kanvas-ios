//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import KanvasCamera
import TumblrTheme
import Photos

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

    private lazy var kanvasController: CameraController = {
        let kanvasAnalyticsProvider = KanvasCameraAnalyticsStub()
        let kanvasViewController = CameraController(settings: kanvasSettings, analyticsProvider: kanvasAnalyticsProvider)
        kanvasViewController.delegate = self
        return kanvasViewController
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
        pageViewController?.moveToViewController(kanvasController, animated: true, direction: .reverse)
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
    func didCreateMedia(media: KanvasCameraMedia?, error: Error?, exportAction: KanvasExportAction) {
        if let media = media {
            save(media: media)
            self.kanvasController.hideOverlay { }
            self.navigateFromKanvas()
        }
        else {
            assertionFailure("Failed to create media")
        }
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

    private func save(media: KanvasCameraMedia) {
        PHPhotoLibrary.requestAuthorization { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                print("Photo Library Authorization: Not Determined... not saving!!")
                return
            case .restricted:
                print("Photo Library Authorization: Restricted... not saving!!")
                return
            case .denied:
                print("Photo Library Authorization: Denied... not saving!!")
                return
            case .authorized:
                print("Photo Library Authorization: Authorized")
            }
        }
        switch media {
        case let .image(url):
            moveToLibrary(url: url, resourceType: .photo)
        case let .video(url):
            moveToLibrary(url: url, resourceType: .video)
        }
    }

    private func moveToLibrary(url: URL, resourceType: PHAssetResourceType) {
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            req.addResource(with: resourceType, fileURL: url, options: options)
        }) { (success, error) in
            guard success else {
                guard let err = error else {
                    assertionFailure("Neigher a success or failure!")
                    return
                }
                assertionFailure("\(err)")
                return
            }
        }
    }
}
