//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// A protocol for the item to be presented in the option selector controller.
protocol OptionSelectorItem {
    
    /// Name of the item.
    var description: String { get }    
}
