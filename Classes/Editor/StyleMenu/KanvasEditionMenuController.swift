//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol KanvasEditionMenuControllerDelegate: class {
    /// Callback for the selection of an option
    ///
    /// - Parameter editionOption: the selected option
    /// - Parameter cell: the selected cell
    func didSelectEditionOption(_ editionOption: EditionOption, cell: KanvasEditionMenuCollectionCell)
}

protocol KanvasEditionMenuController: UIViewController {
    var textCell: KanvasEditionMenuCollectionCell? { get }
    var shouldExportMediaAsGIF: Bool { get set }
    func getCell(for option: EditionOption) -> KanvasEditionMenuCollectionCell?
    func showView(_ show: Bool)
}
