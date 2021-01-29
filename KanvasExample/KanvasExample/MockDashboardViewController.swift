//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol MockDashboardViewControllerDelegate: class {
    func kanvasButtonTapped()
}

class MockDashboardViewController: UIViewController {

    weak var delegate: MockDashboardViewControllerDelegate?

    override func loadView() {
        let view = UIView(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        }
        else {
            view.backgroundColor = .white
        }
        self.view = view

        let label = UILabel(frame: .zero)
        if #available(iOS 13.0, *) {
            label.textColor = .label
        }
        label.text = "↝ Swipe right to open Kanvas ↝"
        label.textAlignment = .center
        label.sizeToFit()
        label.frame.origin.x = (view.bounds.width / CGFloat(2.f)) - (label.frame.width / CGFloat(2.f))
        label.frame.origin.y = (view.bounds.height / CGFloat(2.f)) - (label.frame.height / CGFloat(2.f))
        view.addSubview(label)

        let button = UIButton(frame: .zero)
        button.setTitle("Tap to open Kanvas", for: .normal)
        KanvasCameraAnalyticsStub().logIconPresentedOnDashboard()
        if #available(iOS 13.0, *) {
            button.setTitleColor(.label, for: .normal)
        }
        else {
            button.setTitleColor(.black, for: .normal)
        }
        button.addTarget(self, action: #selector(openKanvas), for: .touchUpInside)
        button.sizeToFit()
        button.frame.origin.x = (view.bounds.width / CGFloat(2.f)) - (button.frame.width / CGFloat(2.f))
        let buttonOffsetTop = 20
        button.frame.origin.y = label.frame.origin.y + label.frame.height + CGFloat(buttonOffsetTop)
        view.addSubview(button)
    }

    @objc func openKanvas() {
        delegate?.kanvasButtonTapped()
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}
