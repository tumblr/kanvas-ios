//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for confirming the text tools

protocol TextControllerDelegate: class {
    
    /// Called after the confirm button is tapped
    func didConfirmText()
}

/// Constants for TextController
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
}

/// A view controller that contains the text tools menu
final class TextController: UIViewController, TextViewDelegate {
    
    weak var delegate: TextControllerDelegate?
    
    private lazy var textView: TextView = {
        let textView = TextView()
        textView.delegate = self
        return textView
    }()
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    init() {
        super.init(nibName: .none, bundle: .none)
    }
    
    override func loadView() {
        view = textView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func setUpView() {
        textView.alpha = 0
    }
    
    // MARK: - TextViewDelegate
    
    func didTapConfirmButton() {
        delegate?.didConfirmText()
    }
    
    // MARK: - Public interface
    
    /// shows or hides the text tools menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.textView.alpha = show ? 1 : 0
        }
    }
}
