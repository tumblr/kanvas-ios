//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import KanvasCamera
import Photos

final class ViewController: UIViewController {

    let button = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        button.setTitle("Start camera!", for: .normal)
        button.addTarget(self, action: #selector(cameraSelected), for: .touchUpInside)
    }

    @objc func cameraSelected() {
        let settings = CameraSettings()
        settings.enabledModes = [.photo, .gif, .stopMotion]
        settings.defaultMode = .stopMotion
        settings.exportStopMotionPhotoAsVideo = true
        let controller = CameraController(settings: settings, analyticsProvider: KanvasCameraAnalyticsStub())
        controller.delegate = self
        self.present(controller, animated: true, completion: .none)
    }

}

extension ViewController: CameraControllerDelegate {
    func didCreateMedia(media: KanvasCameraMedia?, error: Error?) {
        if let media = media {
            switch media {
            case .image(let url):
                if let image = UIImage(contentsOfFile: url.path) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            case .video(let url):
                UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
            }
        }
        dismiss(animated: true, completion: .none)
    }

    func dismissButtonPressed() {
        button.setTitle("It's okay. Try again later!", for: .normal)
        dismiss(animated: true, completion: .none)
    }
}
