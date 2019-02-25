//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct ImagePreviewConstants {
    static let animationDuration: TimeInterval = 0.25
    static let imagePreviewAlpha: CGFloat = 0.35
}

/// The class for controlling the preview image
/// that appears between the camera input and the buttons.
final class ImagePreviewController: UIViewController {
    
    private let imageView = UIImageView()

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.alpha = 0
        view.isUserInteractionEnabled = false
        
        imageView.add(into: view)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = ImagePreviewConstants.imagePreviewAlpha
    }
    
    // MARK: - Public interface
    
    /// sets the translucent image with an animation
    ///
    /// - Parameter image: the image to load
    func setImagePreview(_ image: UIImage?) {
        UIView.transition(with: imageView,
                          duration: ImagePreviewConstants.animationDuration,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in self?.imageView.image = image },
                          completion: nil)
    }
    
    /// shows or hides the image preview with an animation
    ///
    /// - Parameter enabled: true to show, false to hide
    func showImagePreview(_ enabled: Bool) {
        UIView.animate(withDuration: ImagePreviewConstants.animationDuration) { [weak self] in
            self?.view.alpha = enabled ? 1 : 0
        }
    }

    /// returns the current image
    func getImagePreview() -> UIImage? {
        return imageView.image
    }

    /// Is the image preview (ghost frame) visible?
    func imagePreviewVisible() -> Bool {
        return self.view.alpha == 1
    }
}
