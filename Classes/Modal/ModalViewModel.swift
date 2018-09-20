//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

enum ModalButtonsLayout {
    case oneBelowTheOther   /// lays out the buttons vertically
    case oneNextToTheOther  /// lays out the buttons horizontally
}

enum ModalButtons {
    /// one button, with one callback
    case one(title: String, callback: () -> ())
    
    /// two buttons. one is the confirm, the other is cancel. Two callbacks.
    case two(confirmTitle: String, confirmCallback: () -> (), cancelTitle: String, cancelCallback: () -> (), buttonsLayout: ModalButtonsLayout)
}

/// ViewModel with information on the Modal that wants to be shown.
/// It stores information for the UI and callbacks for the interaction.
/// It can represent a modal with only one button or with two buttons.
final class ModalViewModel {

    /// The string to display in the modal
    let text: String
    /// The buttons in the modal
    let buttons: ModalButtons

    /// Initializer for a model with one button
    ///
    /// - Parameters:
    ///   - text: The text to display in the modal
    ///   - buttonTitle: the string to display in the button
    ///   - buttonCallback: the callback for tapping the button
    init(text: String, buttonTitle: String, buttonCallback: @escaping () -> ()) {
        self.text = text
        buttons = .one(title: buttonTitle, callback: buttonCallback)
    }

    /// Initializer for a model with two buttons
    ///
    /// - Parameters:
    ///   - text: The text to display in the modal
    ///   - confirmTitle: The string to display in the confirm button
    ///   - confirmCallback: The callback for tapping the confirm button
    ///   - cancelTitle: The string to display in the cancel button
    ///   - cancelCallback: The callback for tapping the cancel button
    ///   - buttonsLayout: The layout type for the two buttons
    init(text: String, confirmTitle: String, confirmCallback: @escaping () -> (), cancelTitle: String, cancelCallback: @escaping () -> (), buttonsLayout: ModalButtonsLayout) {
        self.text = text
        buttons = .two(confirmTitle: confirmTitle, confirmCallback: confirmCallback, cancelTitle: cancelTitle, cancelCallback: cancelCallback, buttonsLayout: buttonsLayout)
    }

    /// The closure for tapping the confirm button
    var confirmCallback: () -> () {
        switch buttons {
        case .one(title: _, callback: let callback): return callback
        case .two(confirmTitle: _, confirmCallback: let callback, cancelTitle: _, cancelCallback: _, buttonsLayout: _): return callback
        }
    }

    /// The closure for tapping the cancel button
    var cancelCallback: (() -> ())? {
        switch buttons {
        case .one: return .none
        case .two(confirmTitle: _, confirmCallback: _, cancelTitle: _, cancelCallback: let callback, buttonsLayout: _): return callback
        }
    }

    /// The layout for the buttons, can be nil if only one button
    var buttonsLayout: ModalButtonsLayout? {
        switch buttons {
        case .one: return .none
        case .two(confirmTitle: _, confirmCallback: _, cancelTitle: _, cancelCallback: _, buttonsLayout: let layout): return layout
        }
    }

}
