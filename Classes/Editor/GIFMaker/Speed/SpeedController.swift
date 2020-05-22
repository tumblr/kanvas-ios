//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for the speed controller
protocol SpeedControllerDelegate: class {

}

/// A view controller that contains the speed tools menu
final class SpeedController: UIViewController {
    
    weak var delegate: SpeedControllerDelegate?
    
    private lazy var speedView: SpeedView = SpeedView()
    
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
        view = speedView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        speedView.alpha = 0
    }
        
    // MARK: - Public interface
    
    /// shows or hides the speed tools menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        speedView.showView(show)
    }
    
}
