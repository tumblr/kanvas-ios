//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

extension UIViewController {

    /**
     Loads the childViewController into the specified containerView.

     It can be done after self's view is initialized, as it uses constraints to determine the childViewController size.
     Take into account that self will retain the childViewController, so if for any other reason the childViewController is retained in another place, this would
     lead to a memory leak. In that case, one should call unloadViewController().

     - parameter childViewController: The controller to load.
     - parameter into: The containerView into which the controller will be loaded.
     - parameter viewPositioning: Back or Front. Default: Front
     */
    func load(childViewController: UIViewController, into containerView: UIView, viewPositioning: ViewPositioning = .front) {
        childViewController.willMove(toParent: self)
        addChild(childViewController)
        childViewController.didMove(toParent: self)
        childViewController.view.add(into: containerView, in: viewPositioning)
    }

    /**
     Unloads a childViewController and its view from its parentViewController.
     */
    func unloadFromParentViewController() {
        view.removeFromSuperview()
        removeFromParent()
    }

    /**
     Unloads all childViewController and their view from self.
     */
    func unloadChildViewControllers() {
        for childController in self.children {
            childController.unloadFromParentViewController()
        }
    }

}
