//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for tap events on the editor menu.
protocol KanvasEditorMenuControllerDelegate: AnyObject {
    
    /// Callback for the selection of an option.
    ///
    /// - Parameters
    ///  - editionOption: the selected option.
    ///  - cell: the selected cell.
    func didSelectEditionOption(_ editionOption: EditionOption, cell: KanvasEditorMenuCollectionCell)
}

/// Protocol for the editor menu.
protocol KanvasEditorMenuController: UIViewController {
    
    /// Delegate for tap events.
    var delegate: KanvasEditorMenuControllerDelegate? { get set }
    
    /// Whether media should be exported as a GIF or not.
    var shouldExportMediaAsGIF: Bool { get set }
    
    /// Obtains the cell for a given option.
    ///
    /// - Parameter option: an edition option.
    func getCell(for option: EditionOption) -> KanvasEditorMenuCollectionCell?
    
    /// Shows or hides the editor menu.
    ///
    /// - Parameter show: true to show, false to hide.
    func showView(_ show: Bool)
}
