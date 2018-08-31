//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

private struct ModalViewConstants {
    static let Margin: CGFloat = 40
    static let PaddingToText: CGFloat = 24
    static let PaddingBetweenButtons: CGFloat = 10
    static let ContainerCornerRadius: CGFloat = 16
    static let ButtonCornerRadius: CGFloat = 10
    static let TitleFontSize: CGFloat = 22
    static let ButtonFontSize: CGFloat = 16
    static let ContainerColor: UIColor = .white
    static let ConfirmButtonColor: UIColor = UIColor(red: 32/255, green: 185/255, blue: 252/255, alpha: 1)
    static let CancelButtonColor: UIColor = .white
    static let ConfirmButtonTextColor: UIColor = CancelButtonColor
    static let CancelButtonTextColor: UIColor = ConfirmButtonColor
    static let ButtonTextMargin: CGFloat = 15
}

/// The modal view to be presented by a ModalPresentationController
final class ModalView: UIView {

    /// The text label for the view
    let textLabel: UILabel
    
    /// The confirm button for the view
    let confirmButton: UIButton
    
    /// The cancel button for the view. This may be hidden
    let cancelButton: UIButton
    
    /// Can contain another view
    let containerView: UIView

    private var cancelButtonAppearingConstraint: NSLayoutConstraint?
    private var cancelButtonDisappearingConstraint: NSLayoutConstraint?
    private var buttonsSeparationConstraint: NSLayoutConstraint?

    @available(*, unavailable, message: "use init(buttonsLayout:) instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(buttonsLayout:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// The designated initializer
    ///
    /// - Parameter buttonsLayoutyout: can be stacked or side by side buttons
    init(buttonsLayout: ModalButtonsLayout) {
        textLabel = UILabel()
        confirmButton = UIButton()
        cancelButton = UIButton()
        containerView = UIView()
        
        super.init(frame: .zero)
        setUpViews(buttonsLayout: buttonsLayout)

        layer.masksToBounds = false
    }

    // MARK: - configuration

    /// Updates the view for the view model
    ///
    /// - Parameter viewModel: the view model to display
    func configureModal(_ viewModel: ModalViewModel) {
        textLabel.text = viewModel.text
        switch viewModel.buttons {
        case .one(title: let title, callback: _):
            confirmButton.setTitle(title, for: .normal)
            setCancelButton(active: false)
        case .two(confirmTitle: let confirmTitle, confirmCallback: _,
                  cancelTitle: let cancelTitle, cancelCallback: _,
                  buttonsLayout: _):
            confirmButton.setTitle(confirmTitle, for: .normal)
            cancelButton.setTitle(cancelTitle, for: .normal)
            setCancelButton(active: true)
        }
    }

    private func setCancelButton(active: Bool) {
        buttonsSeparationConstraint?.constant = active ? ModalViewConstants.PaddingBetweenButtons : 0
        cancelButtonAppearingConstraint?.isActive = active
        cancelButtonDisappearingConstraint?.isActive = !active
    }

    // MARK: - private

    private func setUpViews(buttonsLayout: ModalButtonsLayout) {
        containerView.add(into: self, respectSafeArea: true)
        containerView.addSubview(textLabel)
        containerView.addSubview(confirmButton)
        containerView.addSubview(cancelButton)
        setUpContainer()
        setUpLabel()
        setUpConfirmButton(buttonsLayout: buttonsLayout)
        setUpCancelButton(buttonsLayout: buttonsLayout)
    }

    private func setUpContainer() {
        containerView.accessibilityIdentifier = "Modal Container View"
        containerView.backgroundColor = ModalViewConstants.ContainerColor
        containerView.layer.cornerRadius = ModalViewConstants.ContainerCornerRadius
        containerView.layer.masksToBounds = true
    }

    private func setUpLabel() {
        textLabel.accessibilityIdentifier = "Modal Text Label"
        textLabel.font = UIFont.systemFont(ofSize: ModalViewConstants.TitleFontSize)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ModalViewConstants.Margin),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ModalViewConstants.Margin),
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ModalViewConstants.Margin),
            textLabel.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -ModalViewConstants.PaddingToText)
        ])
    }

    private func setUpConfirmButton(buttonsLayout: ModalButtonsLayout) {
        configureButton(button: confirmButton, isConfirmButton: true)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        let separationConstraint: NSLayoutConstraint
        let variableConstraint: NSLayoutConstraint
        switch buttonsLayout {
        case .oneNextToTheOther:
            separationConstraint = confirmButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: ModalViewConstants.PaddingBetweenButtons)
            variableConstraint = confirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ModalViewConstants.Margin)
        case .oneBelowTheOther:
            separationConstraint = cancelButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: ModalViewConstants.PaddingBetweenButtons)
            variableConstraint = confirmButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ModalViewConstants.Margin)
        }
        buttonsSeparationConstraint = separationConstraint
        NSLayoutConstraint.activate([
            separationConstraint,
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ModalViewConstants.Margin),
            variableConstraint
        ])
    }

    private func setUpCancelButton(buttonsLayout: ModalButtonsLayout) {
        configureButton(button: cancelButton, isConfirmButton: false)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = cancelButton.widthAnchor.constraint(equalTo: confirmButton.widthAnchor)
        let heightConstraint = cancelButton.heightAnchor.constraint(equalTo: confirmButton.heightAnchor)
        let variableConstraint: NSLayoutConstraint
        switch buttonsLayout {
        case .oneNextToTheOther:
            cancelButtonDisappearingConstraint = cancelButton.widthAnchor.constraint(equalToConstant: 0)
            cancelButtonAppearingConstraint = widthConstraint
            variableConstraint = cancelButton.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor)
        case .oneBelowTheOther:
            cancelButtonDisappearingConstraint = cancelButton.heightAnchor.constraint(equalToConstant: 0)
            cancelButtonAppearingConstraint = heightConstraint
            variableConstraint = cancelButton.centerXAnchor.constraint(equalTo: confirmButton.centerXAnchor)
        }
        NSLayoutConstraint.activate([
            heightConstraint,
            widthConstraint,
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ModalViewConstants.Margin),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ModalViewConstants.Margin),
            variableConstraint
        ])

    }

    private func configureButton(button: UIButton, isConfirmButton: Bool) {
        button.layer.cornerRadius = ModalViewConstants.ButtonCornerRadius
        button.layer.masksToBounds = true
        button.setTitle("", for: .normal)   // Needed so there is a title label which we can set font to.
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: ModalViewConstants.ButtonFontSize)
        button.titleLabel?.numberOfLines = 0
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.backgroundColor = isConfirmButton ? ModalViewConstants.ConfirmButtonColor : ModalViewConstants.CancelButtonColor
        button.setTitleColor(isConfirmButton ? ModalViewConstants.ConfirmButtonTextColor : ModalViewConstants.CancelButtonTextColor, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: ModalViewConstants.ButtonTextMargin,
                                                left: ModalViewConstants.ButtonTextMargin,
                                                bottom: ModalViewConstants.ButtonTextMargin,
                                                right: ModalViewConstants.ButtonTextMargin)

        button.accessibilityIdentifier = "Modal \(isConfirmButton ? "Confirm" : "Cancel") Button"
    }
    
}
