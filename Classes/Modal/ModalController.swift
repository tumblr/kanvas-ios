//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Controller for handling a modal.
///
/// Should be used like:
/// ```
/// let viewModel = ModalViewModel(...)
/// let controller = ModalController(viewModel: viewModel)
/// navigationController.present(controller)
/// ```
final class ModalController: UIViewController {

    private lazy var modalView: ModalView = ModalView(buttonsLayout: self.viewModel.buttonsLayout ?? .oneBelowTheOther)
    private let viewModel: ModalViewModel

    /// Initializer for modal controller with a view model
    ///
    /// - Parameter viewModel: The view model to display in the controller's view
    public init(viewModel: ModalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: .none, bundle: .none)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    override public func loadView() {
        view = modalView
        modalView.configureModal(viewModel)
    }

    override public func viewDidLoad() {
        configureButtons()
        super.viewDidLoad()
    }

    @available(*, unavailable, message: "use init(viewModel:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(viewModel:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    // MARK: - Buttons

    private func configureButtons() {
        modalView.confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        modalView.cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
    }

    @objc private func confirmButtonPressed() {
        dismiss(animated: true) { [unowned self] in self.viewModel.confirmCallback() }
    }

    @objc private func cancelButtonPressed() {
        dismiss(animated: true) { [unowned self] in self.viewModel.cancelCallback?() }
    }

}

// MARK: - Presentation
extension ModalController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController)
        -> UIPresentationController? {
            return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return ModalPresentationAnimationController(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return ModalPresentationAnimationController(isPresenting: false)
    }

}
