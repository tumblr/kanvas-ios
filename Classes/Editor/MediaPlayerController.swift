//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for the editor and preview controller
protocol MediaPlayerController: UIViewController {
    /// Called when the Posting Options view is dismissed.
    func onPostingOptionsDismissed()
    
    /// Called when the post button with quick options is submitted.
    func onQuickPostButtonSubmitted()
    
    /// Called when the quick post options in the Editor change their visibility.
    ///
    /// - Parameters
    ///  - visible: true if the quick options are visible, false if not.
    ///  - hintText: an optional text to show as hint.
    ///  - view: the view that starts the action.
    func onQuickPostOptionsShown(visible: Bool, hintText: String?, view: UIView)
    
    /// Called when the user enters or leaves the selection area.
    ///
    /// - Parameters
    ///  - selected: true if the user is in the selection area, false if not.
    ///  - hintText: an optional text to show as hint.
    ///  - view: the view that starts the action.
    func onQuickPostOptionsSelected(selected: Bool, hintText: String?, view: UIView)
    
}
