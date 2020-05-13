//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for the trim controller
protocol TrimControllerDelegate: class {
    
}

/// Constants for TrimController
private struct Constants {
    // TODO: Add constants
}

/// A view controller that contains the trim menu
final class TrimController: UIViewController, TrimViewDelegate {
    
    weak var delegate: TrimControllerDelegate?
        
    private lazy var trimView: TrimView = {
        let view = TrimView()
        view.delegate = self
        return view
    }()

    // MARK: - Initializers
    
    init() {
        super.init(nibName: .none, bundle: .none)
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func loadView() {
        view = trimView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        trimView.alpha = 0
    }
    
    // MARK: - TrimViewDelegate
    
    func didMoveTrimArea(from startingPercentage: CGFloat, to finalPercentage: CGFloat) {
        print("L - start \(startingPercentage) - end \(finalPercentage)")
    }
    
    // MARK: - Public interface
    
    /// shows or hides the trim menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        trimView.showView(show)
    }
    
}
