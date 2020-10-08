//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Protocol for the editor and preview controller
protocol MediaPlayerController: UIViewController {
    /// Called when the Posting Options view is dismissed.
    func onPostingOptionsDismissed()
    
    /// Called when the post button with quick options is submitted.
    func onQuickPostButtonSubmitted()
    
    /// Called when the quick post options in the Editor change their visibility.
    ///
    /// - Parameter visible: true if the quick options are visible, false if not.
    func onQuickPostOptionsShown(_ visible: Bool)
    
    /// Called when the user enters or leaves the selection area.
    ///
    /// - Parameter isInSelectionArea: true if the user is in the selection area, false if not.
    func onQuickPostOptionsSelected(_ isInSelectionArea: Bool)
    
}
