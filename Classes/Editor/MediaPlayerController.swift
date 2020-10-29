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
}
