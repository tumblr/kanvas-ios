//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import Photos
import KanvasCamera
import Photos

/// Protocol for the KanvasDashboardController to delegate events to
public protocol KanvasDashboardControllerDelegate: class {

    /// Called when the dismiss button is pressed in the camera
    func kanvasDashboardDismissRequest()

    /// Called when a user doesn't have a full account
    func kanvasDashboardNeedsAccount()

    /// Called to open the post compose form
    func kanvasDashboardOpenComposeRequest()

    /// Called to post
    func kanvasDashboardCreatePostRequest()
}

/// Protocol for the KanvasDashboardController to get state from
/// This is an alternative to passing this state in through a constructor
public protocol KanvasDashboardStateDelegate: class {

    /// The EventBuffering for Kanvas Dashboard to use
    var kanvasDashboardAnalyticsProvider: KanvasCameraAnalyticsProvider { get }

    /// The blog UUID for Kanvas Dashboard to post to
    var kanvasDashboardBlogUUID: String? { get }
}

/// KanvasDashboardController: the view controller for Kanvas on the Dashboard
public class KanvasDashboardController: UIViewController {

    private struct Constants {
        static let pixelWidthKey = "PixelWidth"
        static let pixelHeightKey = "PixelHeight"
    }

    private let settings: CameraSettings

    public weak var delegate: KanvasDashboardControllerDelegate?

    public weak var stateDelegate: KanvasDashboardStateDelegate?

    private var kanvasCleanupTimer: Timer?

    init(settings: CameraSettings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let view = UIView(frame: .zero)
        self.view = view
        self.loadKanvasView()
    }

    override public var childForStatusBarStyle: UIViewController? {
        return kanvasViewController
    }

    public func logOpen(withTap openedWithTap: Bool) {
        if !openedWithTap {
            stateDelegate?.kanvasDashboardAnalyticsProvider.logOpenFromDashboard(openAction: .swipe)
        }
        else {
            stateDelegate?.kanvasDashboardAnalyticsProvider.logOpenFromDashboard(openAction: .tap)
        }
    }

    public func logDismiss(withTap dismissedWithTap: Bool) {
        if !dismissedWithTap {
            stateDelegate?.kanvasDashboardAnalyticsProvider.logDismissFromDashboard(dismissAction: .swipe)
        }
        else {
            stateDelegate?.kanvasDashboardAnalyticsProvider.logDismissFromDashboard(dismissAction: .tap)
        }
    }

    private var _kanvasViewControllerBackingProperty: CameraController?
    private var kanvasViewController: CameraController {
        if let kanvasViewControllerInstance = _kanvasViewControllerBackingProperty {
            return kanvasViewControllerInstance
        }
        let kanvasViewControllerInstance = createCameraController()
        _kanvasViewControllerBackingProperty = kanvasViewControllerInstance
        return kanvasViewControllerInstance
    }
}

extension KanvasDashboardController: CameraControllerDelegate {

    public func didCreateMedia(media: KanvasCameraMedia?, exportAction: KanvasExportAction, error: Error?) {
        if let error = error {
            assertionFailure("Error creating Kanvas media: \(error)")
            return
        }
        guard let media = media else {
            assertionFailure("No error, but no media!?")
            return
        }

        save(media: media, moveFile: false)

        switch exportAction {
        case .previewConfirm:
            assertionFailure("The Preview screen should never be shown from the Kanvas Dashboard")
        case .confirm:
            kanvasViewController.resetState()
            delegate?.kanvasDashboardOpenComposeRequest()
        case .post:
            kanvasViewController.resetState()
            delegate?.kanvasDashboardCreatePostRequest()
        case .save:
            // nothing to do since the media was saved already
            break
        }
    }

    public func dismissButtonPressed() {
        delegate?.kanvasDashboardDismissRequest()
    }

    public func didDismissWelcomeTooltip() {

    }

    public func cameraShouldShowWelcomeTooltip() -> Bool {
        return false
    }

    public func provideMediaPickerThumbnail(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        completion(nil)
    }

    public func didDismissColorSelectorTooltip() {

    }

    public func editorShouldShowColorSelectorTooltip() -> Bool {
        return false
    }

    public func didEndStrokeSelectorAnimation() {

    }

    public func editorShouldShowStrokeSelectorAnimation() -> Bool {
        return false
    }
    
    public func didBeginDragInteraction() {
        
    }
    
    public func didEndDragInteraction() {
        
    }

    func save(media: KanvasCameraMedia, moveFile: Bool = true) {
        PHPhotoLibrary.requestAuthorization { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined, .restricted, .denied:
                return
            case .authorized:
                break
            @unknown default:
                return
            }
        }
        switch media {
        case let .image(url):
            addToLibrary(url: url, resourceType: .photo, moveFile: moveFile)
        case let .video(url):
            addToLibrary(url: url, resourceType: .video, moveFile: moveFile)
        }
    }

    private func addToLibrary(url: URL, resourceType: PHAssetResourceType, moveFile: Bool) {
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = moveFile
            req.addResource(with: resourceType, fileURL: url, options: options)
        }) { (success, error) in
            if !success {
                if let err = error {
                    assertionFailure("Error saving media to the photo library: \(err)")
                }
                else {
                    assertionFailure("Neither a success or failure!?")
                }
            }
        }
    }
}

private extension KanvasDashboardController {

    func createCameraController() -> CameraController {
        let kanvasAnalyticsProvider = stateDelegate?.kanvasDashboardAnalyticsProvider
        let kanvasViewController = CameraController(settings: settings, analyticsProvider: kanvasAnalyticsProvider)
        kanvasViewController.delegate = self
        return kanvasViewController
    }

    func loadKanvasView() {
        if !children.contains(kanvasViewController), let kanvasView = kanvasViewController.view {
            kanvasView.translatesAutoresizingMaskIntoConstraints = false
            addChild(kanvasViewController)
            view.addSubview(kanvasView)
            NSLayoutConstraint.activate([
                kanvasView.topAnchor.constraint(equalTo: view.topAnchor),
                kanvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                kanvasView.leftAnchor.constraint(equalTo: view.leftAnchor),
                kanvasView.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])
        }
    }

    func unloadKanvasView() {
        if let kanvasView = kanvasViewController.view {
            kanvasView.removeFromSuperview()
            kanvasViewController.removeFromParent()
        }
    }

}

extension KanvasDashboardController {

    public func pageWillBecomeVisible() {
        if let kanvasCleanupTimer = kanvasCleanupTimer {
            kanvasCleanupTimer.invalidate()
            self.kanvasCleanupTimer = nil
        }
        else {
            loadKanvasView()
        }
    }

    public func pageDidBecomeHidden() {
        let kanvasCleanupTimer = Timer(fire: .init(timeIntervalSinceNow: 10.0), interval: 0, repeats: false) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if let kanvasViewControllerInstance = strongSelf._kanvasViewControllerBackingProperty {
                kanvasViewControllerInstance.cleanup()
                strongSelf.unloadKanvasView()
                strongSelf._kanvasViewControllerBackingProperty = nil
                strongSelf.kanvasCleanupTimer?.invalidate()
                strongSelf.kanvasCleanupTimer = nil
            }
        }
        kanvasCleanupTimer.tolerance = 1.0
        RunLoop.current.add(kanvasCleanupTimer, forMode: .common)
        self.kanvasCleanupTimer = kanvasCleanupTimer
    }

    public func pageGainedFocus() {

    }
}
