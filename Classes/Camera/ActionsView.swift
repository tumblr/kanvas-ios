//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

private struct ActionsViewConstants {
    static let ButtonMargin: CGFloat = CameraConstants.ButtonMargin * 3/2
    static let ButtonSize: CGFloat = 50
    static let AnimationDuration: TimeInterval = 0.5
}

/// Protocol for handling ActionsView's interaction.
protocol ActionsViewDelegate: class {
    /// A function that is called when the undo button is pressed
    func undoButtonPressed()
    /// A function that is called when the next button is pressed
    func nextButtonPressed()
}

final class ActionsView: IgnoreTouchesView {

    private let nextButton: UIButton
    private let undoButton: UIButton

    weak var delegate: ActionsViewDelegate?

    init() {
        nextButton = UIButton()
        undoButton = UIButton()

        super.init(frame: .zero)

        setUpUndoButton(image: KanvasCameraImages.UndoImage)
        setUpNextButton(image: KanvasCameraImages.NextImage)
    }

    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates UI for the undo button
    ///
    /// - Parameter enabled: whether to enable the undo button or not
    func updateUndo(enabled: Bool) {
        UIView.animate(withDuration: ActionsViewConstants.AnimationDuration) {
            self.undoButton.alpha = enabled ? 1 : 0
        }
    }

    /// Updates UI for the next button
    ///
    /// - Parameter enabled: whether to enable the next button or not
    func updateNext(enabled: Bool) {
        UIView.animate(withDuration: ActionsViewConstants.AnimationDuration) {
            self.nextButton.alpha = enabled ? 1 : 0
        }
    }
    // MARK: - UI Layout

    private func setUpUndoButton(image: UIImage?) {
        undoButton.accessibilityIdentifier = "Undo Button"
        undoButton.setImage(image, for: .normal)
        undoButton.contentMode = .scaleAspectFit
        undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)

        addSubview(undoButton)
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            undoButton.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor),
            undoButton.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor, constant: ActionsViewConstants.ButtonMargin),
            undoButton.heightAnchor.constraint(equalTo: undoButton.widthAnchor),
            undoButton.widthAnchor.constraint(equalToConstant: ActionsViewConstants.ButtonSize)
        ])
    }

    private func setUpNextButton(image: UIImage?) {
        nextButton.accessibilityIdentifier = "Next Button"
        nextButton.setImage(image, for: .normal)
        nextButton.contentMode = .scaleAspectFit
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -ActionsViewConstants.ButtonMargin),
            nextButton.heightAnchor.constraint(equalTo: nextButton.widthAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: ActionsViewConstants.ButtonSize)
        ])
    }

    // MARK: - Buttons actions

    @objc private func undoTapped() {
        delegate?.undoButtonPressed()
    }

    @objc private func nextTapped() {
        delegate?.nextButtonPressed()
    }

}
