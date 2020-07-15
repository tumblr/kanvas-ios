//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

struct FullViewConstraints {
    weak var view: UIView?
    let top: NSLayoutConstraint
    let bottom: NSLayoutConstraint
    let leading: NSLayoutConstraint
    let trailing: NSLayoutConstraint

    @discardableResult func activate() -> FullViewConstraints {
        NSLayoutConstraint.activate([top, bottom, leading, trailing])
        return self
    }

    func update(with rect: CGRect) {
        guard let superRect = view?.superview?.bounds else {
            assertionFailure("Could not update constraints")
            return
        }
        top.constant = rect.origin.y
        bottom.constant = -(superRect.height - (rect.origin.y + rect.height))
        leading.constant = rect.origin.x
        trailing.constant = -(superRect.width - (rect.origin.x + rect.width))
        view?.updateConstraints()
    }
}

/// protocol for closing the preview or confirming
protocol EditorViewDelegate: class {
    /// A function that is called when the confirm button is pressed
    func didTapConfirmButton()
    /// A function that is called when the close button is pressed
    func didTapCloseButton()
    /// A function that is called when the post button is pressed
    func didTapPostButton()
    /// A function that is called when the save button is pressed
    func didTapSaveButton()
    func didTapPostOptionsButton()
    /// Called when a touch event on a movable view begins
    func didBeginTouchesOnText()
    /// Called when the touch events on a movable view end
    func didEndTouchesOnText()
    /// A function that is called when the tag button is pressed
    func didTapTagButton()
    /// A function that is called when a movable text is pressed
    func didTapText(options: TextOptions, transformations: ViewTransformations)
    /// Called when text is moved
    func didMoveText()
    /// Called when text is removed
    func didRemoveText()
    /// Called when an image is moved
    ///
    ///  - Parameter imageView:the image view that was moved
    func didMoveImage(_ imageView: StylableImageView)
    /// Called when an image is removed
    ///
    ///  - Parameter imageView:the image view that was removed
    func didRemoveImage(_ imageView: StylableImageView)
    /// Called when the rendering rectangle has changed
    /// - Parameter rect: the rendering rectangle
    func didRenderRectChange(rect: CGRect)
}

/// Constants for EditorView
private struct EditorViewConstants {
    static let animationDuration: TimeInterval = 0.25
    static let editionOptionAnimationDuration: TimeInterval = 0.5
    static let confirmButtonSize: CGFloat = 49
    static let confirmButtonHorizontalMargin: CGFloat = 20
    static let confirmButtonVerticalMargin: CGFloat = Device.belongsToIPhoneXGroup ? 14 : 19.5
    static let postButtonSize: CGFloat = 54
    static let postButtonHorizontalMargin: CGFloat = 18
    static let postButtonVerticalMargin: CGFloat = Device.belongsToIPhoneXGroup ? 13 : 29
    static let postButtonLabelMargin: CGFloat = 3
    static let saveButtonSize: CGFloat = 34
    static let saveButtonHorizontalMargin: CGFloat = 20
    static let fakeOptionCellMinSize: CGFloat = 36
    static let fakeOptionCellMaxSize: CGFloat = 45
    static let frame: CGRect = .init(x: 0, y: 0, width: EditorViewConstants.postButtonSize, height: EditorViewConstants.postButtonSize)
}

/// A UIView to preview the contents of segments without exporting

final class EditorView: UIView, MovableViewCanvasDelegate, MediaPlayerViewDelegate {

    func didRenderRectChange(rect: CGRect) {
        drawingCanvasConstraints.update(with: rect)
        movableViewCanvasConstraints.update(with: rect)
        delegate?.didRenderRectChange(rect: rect)
    }

    enum MainActionMode {
        case confirm
        case post
        case postOptions
    }
    
    weak var playerView: MediaPlayerView?

    private let mainActionMode: MainActionMode
    private let confirmButton = UIButton()
    private let closeButton = UIButton()
    private let saveButton = UIButton()
    private let showSaveButton: Bool
    private let showCrossIcon: Bool
    private let postButton = UIButton()
    private let postLabel = UILabel()
    private let tagButton = UIButton()
    private let fakeOptionCell = UIImageView()
    private let showTagButton: Bool
    private let filterSelectionCircle = UIImageView()
    private let navigationContainer = IgnoreTouchesView()
    let collectionContainer = IgnoreTouchesView()
    let filterMenuContainer = IgnoreTouchesView()
    let textMenuContainer = IgnoreTouchesView()
    let drawingMenuContainer = IgnoreTouchesView()
    let gifMakerMenuContainer = IgnoreTouchesView()
    private let quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?

    let drawingCanvas = IgnoreTouchesView()

    private lazy var drawingCanvasConstraints: FullViewConstraints = {
        return FullViewConstraints(
            view: drawingCanvas,
            top: drawingCanvas.topAnchor.constraint(equalTo: topAnchor),
            bottom: drawingCanvas.bottomAnchor.constraint(equalTo: bottomAnchor),
            leading: drawingCanvas.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailing: drawingCanvas.trailingAnchor.constraint(equalTo: trailingAnchor)
        )
    }()

    lazy var movableViewCanvas: MovableViewCanvas = {
        let canvas = MovableViewCanvas()
        canvas.delegate = self
        return canvas
    }()

    private lazy var movableViewCanvasConstraints = {
        return FullViewConstraints(
            view: movableViewCanvas,
            top: movableViewCanvas.topAnchor.constraint(equalTo: topAnchor),
            bottom: movableViewCanvas.bottomAnchor.constraint(equalTo: bottomAnchor),
            leading: movableViewCanvas.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailing: movableViewCanvas.trailingAnchor.constraint(equalTo: trailingAnchor)
        )
    }()

    var avatarView: UIView? {
        return quickBlogSelectorCoordinator?.avatarView(frame: EditorViewConstants.frame)
    }
    
    weak var delegate: EditorViewDelegate?
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(mainActionMode: MainActionMode, showSaveButton: Bool, showCrossIcon: Bool, showTagButton: Bool, quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?) {
        self.mainActionMode = mainActionMode
        self.showSaveButton = showSaveButton
        self.showTagButton = showTagButton
        self.showCrossIcon = showCrossIcon
        self.quickBlogSelectorCoordinator = quickBlogSelectorCoordinator
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        setupPlayer()
        setupDrawingCanvas()
        setupMovableViewCanvas()
        setupNavigationContainer()
        setupCloseButton()
        if showTagButton {
            setupTagButton()
        }
        switch mainActionMode {
        case .confirm:
            setupConfirmButton()
        case .post:
            setupPostButton()
        case .postOptions:
            setupPostOptionsButton()
        }
        if showSaveButton {
            setupSaveButton()
        }
        setupCollection()
        setupFilterMenu()
        setupTextMenu()
        setupDrawingMenu()
        setupGifMakerMenu()
        setupFakeOptionCell()
    }
    
    // MARK: - views

    private func setupPlayer() {
        let playerView = MediaPlayerView()
        playerView.delegate = self
        playerView.add(into: self)
        self.playerView = playerView
    }

    private func setupDrawingCanvas() {
        drawingCanvas.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(drawingCanvas)
        drawingCanvasConstraints.activate()
    }

    private func setupMovableViewCanvas() {
        movableViewCanvas.translatesAutoresizingMaskIntoConstraints = false
        movableViewCanvas.clipsToBounds = true
        addSubview(movableViewCanvas)
        movableViewCanvasConstraints.activate()
    }
    
    /// Container that holds the back button and the bottom menu
    private func setupNavigationContainer() {
        navigationContainer.accessibilityIdentifier = "Navigation Container"
        navigationContainer.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(navigationContainer)
        NSLayoutConstraint.activate([
            navigationContainer.topAnchor.constraint(equalTo: topAnchor),
            navigationContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            navigationContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationContainer.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupTagButton() {
        tagButton.accessibilityLabel = "Tag Button"
        tagButton.layer.applyShadows()
        tagButton.setImage(KanvasCameraImages.tagImage, for: .normal)
        tagButton.imageView?.contentMode = .scaleAspectFit
        tagButton.imageView?.tintColor = .white

        navigationContainer.addSubview(tagButton)
        tagButton.addTarget(self, action: #selector(tagButtonPressed), for: .touchUpInside)
        tagButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagButton.trailingAnchor.constraint(equalTo: navigationContainer.trailingAnchor, constant: -CameraConstants.optionHorizontalMargin),
            tagButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.optionVerticalMargin),
            tagButton.heightAnchor.constraint(equalTo: tagButton.widthAnchor),
            tagButton.widthAnchor.constraint(equalToConstant: CameraConstants.optionButtonSize)
        ])
    }
    
    private func setupCloseButton() {
        closeButton.accessibilityLabel = "Close Button"
        closeButton.layer.applyShadows()
        let backIcon = showCrossIcon ? KanvasCameraImages.closeImage : KanvasCameraImages.backImage
        closeButton.setImage(backIcon, for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        
        navigationContainer.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor, constant: CameraConstants.optionHorizontalMargin),
            closeButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.optionVerticalMargin),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: CameraConstants.optionButtonSize)
        ])
    }
    
    private func setupConfirmButton() {
        confirmButton.accessibilityLabel = "Confirm Button"
        navigationContainer.addSubview(confirmButton)
        confirmButton.setImage(KanvasCameraImages.nextImage, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            confirmButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -EditorViewConstants.confirmButtonHorizontalMargin),
            confirmButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
            confirmButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -EditorViewConstants.confirmButtonVerticalMargin)
        ])
    }

    private func setupPostOptionsButton() {
        confirmButton.accessibilityLabel = "Post Options Button"
        navigationContainer.addSubview(confirmButton)
        confirmButton.setImage(KanvasCameraImages.nextImage, for: .normal)
        confirmButton.addTarget(self, action: #selector(postOptionsButtonPressed), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            confirmButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -EditorViewConstants.confirmButtonHorizontalMargin),
            confirmButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
            confirmButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -EditorViewConstants.confirmButtonVerticalMargin)
        ])
    }
    
    private func setupCollection() {
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Edition Menu Collection Container"
        collectionContainer.clipsToBounds = false
        
        navigationContainer.addSubview(collectionContainer)
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        let buttonOnTheRight: UIButton
        let trailingMargin: CGFloat
        
        if showSaveButton {
            buttonOnTheRight = saveButton
            trailingMargin = EditorViewConstants.saveButtonHorizontalMargin
        }
        else {
            buttonOnTheRight = confirmOrPostButton()
            trailingMargin = confirmOrPostButtonHorizontalMargin()
        }
        
        NSLayoutConstraint.activate([
            collectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: buttonOnTheRight.leadingAnchor, constant: -trailingMargin / 2),
            collectionContainer.centerYAnchor.constraint(equalTo: confirmOrPostButton().centerYAnchor),
            collectionContainer.heightAnchor.constraint(equalToConstant: EditionMenuCollectionView.height)
        ])
    }
    
    private func setupFilterMenu() {
        filterMenuContainer.backgroundColor = .clear
        filterMenuContainer.accessibilityIdentifier = "Filter Menu Container"
        filterMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        filterMenuContainer.clipsToBounds = false
        
        addSubview(filterMenuContainer)
        NSLayoutConstraint.activate([
            filterMenuContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            filterMenuContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            filterMenuContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            filterMenuContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTextMenu() {
        textMenuContainer.backgroundColor = .clear
        textMenuContainer.accessibilityIdentifier = "Text Menu Container"
        textMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        textMenuContainer.clipsToBounds = false
        
        addSubview(textMenuContainer)
        NSLayoutConstraint.activate([
            textMenuContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            textMenuContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            textMenuContainer.topAnchor.constraint(equalTo: topAnchor),
            textMenuContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupDrawingMenu() {
        drawingMenuContainer.backgroundColor = .clear
        drawingMenuContainer.accessibilityIdentifier = "Drawing Menu Container"
        drawingMenuContainer.clipsToBounds = false
        
        addSubview(drawingMenuContainer)
        drawingMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawingMenuContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            drawingMenuContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            drawingMenuContainer.topAnchor.constraint(equalTo: topAnchor),
            drawingMenuContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupGifMakerMenu() {
        gifMakerMenuContainer.backgroundColor = .clear
        gifMakerMenuContainer.accessibilityIdentifier = "GIF Maker Menu Container"
        gifMakerMenuContainer.clipsToBounds = false
        
        addSubview(gifMakerMenuContainer)
        gifMakerMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gifMakerMenuContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            gifMakerMenuContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            gifMakerMenuContainer.topAnchor.constraint(equalTo: topAnchor),
            gifMakerMenuContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// Sets up the image used for the animation that transforms a menu cell into a checkmark button
    private func setupFakeOptionCell() {
        fakeOptionCell.accessibilityLabel = "Fake Option Cell"
        
        addSubview(fakeOptionCell)
        fakeOptionCell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fakeOptionCell.centerXAnchor.constraint(equalTo: centerXAnchor),
            fakeOptionCell.centerYAnchor.constraint(equalTo: centerYAnchor),
            fakeOptionCell.heightAnchor.constraint(equalToConstant: EditorViewConstants.fakeOptionCellMaxSize),
            fakeOptionCell.widthAnchor.constraint(equalToConstant: EditorViewConstants.fakeOptionCellMaxSize),
        ])
        
        fakeOptionCell.alpha = 0
    }

    func setupPostButton() {
        postButton.accessibilityLabel = "Post Button"
        postButton.clipsToBounds = false
        postButton.layer.applyShadows()
        navigationContainer.addSubview(postButton)
        if let avatarView = self.avatarView {
            updatePostButton(avatarView: avatarView)
        }
        else {
            postButton.setImage(KanvasCameraImages.nextImage, for: .normal)
        }
        postButton.contentHorizontalAlignment = .fill
        postButton.contentVerticalAlignment = .fill
        postButton.translatesAutoresizingMaskIntoConstraints = false

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(postButtonPressed))
        postButton.addGestureRecognizer(tapGestureRecognizer)
        
        NSLayoutConstraint.activate([
            postButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -EditorViewConstants.postButtonHorizontalMargin),
            postButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.postButtonSize),
            postButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.postButtonSize),
            postButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -EditorViewConstants.postButtonVerticalMargin)
        ])
        
        postLabel.text = NSLocalizedString("Post", comment: "Message for the post button in the editor screen")
        postLabel.textColor = .white
        postLabel.font = KanvasCameraFonts.shared.postLabelFont
        postLabel.clipsToBounds = false
        postLabel.layer.applyShadows()
        postLabel.translatesAutoresizingMaskIntoConstraints = false
        postLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postButtonPressed)))
        postLabel.isUserInteractionEnabled = true
        navigationContainer.addSubview(postLabel)
        
        NSLayoutConstraint.activate([
            postLabel.centerXAnchor.constraint(equalTo: postButton.centerXAnchor),
            postLabel.topAnchor.constraint(equalTo: postButton.bottomAnchor, constant: EditorViewConstants.postButtonLabelMargin),
        ])

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(postButtonLongPressed(_:)))
        longPressRecognizer.allowableMovement = 10.0
        longPressRecognizer.minimumPressDuration = 0.4
        postButton.addGestureRecognizer(longPressRecognizer)
    }

    func setupSaveButton() {
        saveButton.accessibilityLabel = "Save Button"
        navigationContainer.addSubview(saveButton)
        saveButton.layer.applyShadows()
        saveButton.setImage(KanvasCameraImages.saveImage, for: .normal)
        saveButton.imageView?.tintColor = .white
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            saveButton.trailingAnchor.constraint(equalTo: confirmOrPostButton().leadingAnchor, constant: -EditorViewConstants.saveButtonHorizontalMargin),
            saveButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.saveButtonSize),
            saveButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.saveButtonSize),
            saveButton.centerYAnchor.constraint(equalTo: confirmOrPostButton().centerYAnchor)
        ])
    }

    func confirmOrPostButton() -> UIButton {
        switch mainActionMode {
        case .confirm, .postOptions:
            return confirmButton
        case .post:
            return postButton
        }
    }
    
    func confirmOrPostButtonHorizontalMargin() -> CGFloat {
        switch mainActionMode {
        case .confirm, .postOptions:
            return EditorViewConstants.confirmButtonHorizontalMargin
        case .post:
            return EditorViewConstants.postButtonHorizontalMargin
        }
    }
    
    // MARK: - buttons
    @objc private func closeButtonPressed() {
        delegate?.didTapCloseButton()
    }

    @objc private func tagButtonPressed() {
        delegate?.didTapTagButton()
    }
    
    @objc private func confirmButtonPressed() {
        delegate?.didTapConfirmButton()
    }

    @objc private func saveButtonPressed() {
        delegate?.didTapSaveButton()
    }

    @objc private func postButtonPressed(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .began: break
        case .changed: break
        case .ended:
            delegate?.didTapPostButton()
        case .cancelled: break
        case .failed: break
        case .possible: break
        @unknown default: break
        }
    }

    @objc private func postButtonLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        guard let quickBlogSelectorCoordinator = quickBlogSelectorCoordinator else {
            return
        }
        switch recognizer.state {
        case .began:
            quickBlogSelectorCoordinator.present(presentingView: self, fromPoint: postButton.center)
        case .ended, .cancelled, .failed:
            quickBlogSelectorCoordinator.dismiss()
            if let avatarView = self.avatarView {
                updatePostButton(avatarView: avatarView)
            }
        case .changed:
            let location = recognizer.location(in: self)
            quickBlogSelectorCoordinator.touchDidMoveToPoint(location)
        case .possible: break
        @unknown default: break
        }
    }

    @objc private func postOptionsButtonPressed() {
        delegate?.didTapPostOptionsButton()
    }

    // MARK: - Public interface
    
    /// shows or hides the navigation container
    ///
    /// - Parameter show: true to show, false to hide
    func showNavigationContainer(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.navigationContainer.alpha = show ? 1 : 0
        }
    }
    
    /// transforms an option cell into a checkmark button with an animation
    ///
    /// - Parameter cell: the cell to be transformed
    /// - Parameter finalLocation: the location where the checkmark button will be
    /// - Parameter completion: a closure to execute when the animation ends
    func animateEditionOption(cell: EditionMenuCollectionCell?, finalLocation: CGPoint, completion: @escaping () -> Void) {
        guard let cell = cell, let cellParent = cell.superview else { return }
        fakeOptionCell.center = cellParent.convert(cell.center, to: nil)
        fakeOptionCell.image = cell.circleView.image
        fakeOptionCell.alpha = 1
        cell.alpha = 0
        
        let duration = EditorViewConstants.editionOptionAnimationDuration
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45 / duration, animations: {
                self.fakeOptionCell.image = KanvasCameraImages.confirmImage
                let scale = EditorViewConstants.fakeOptionCellMinSize / EditorViewConstants.fakeOptionCellMaxSize
                self.fakeOptionCell.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.fakeOptionCell.center = finalLocation
            })
        }, completion: { _ in
            self.fakeOptionCell.alpha = 0
            completion()
        })
    }
    
    /// transforms the checkmark button of the current menu into its option cell with an animation
    ///
    /// - Parameter cell: the cell in which the checkmark button will be tranformed
    func animateReturnOfEditionOption(cell: EditionMenuCollectionCell?) {
        guard let cell = cell, let cellParent = cell.superview else { return }
        fakeOptionCell.alpha = 1
        
        let duration = EditorViewConstants.editionOptionAnimationDuration
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45 / duration, animations: {
                self.fakeOptionCell.image = cell.circleView.image
                self.fakeOptionCell.transform = .identity
                self.fakeOptionCell.center = cellParent.convert(cell.center, to: nil)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.45 / duration, relativeDuration: 0.05 / duration, animations: {
                self.fakeOptionCell.alpha = 0
                cell.alpha = 1
            })
        })
    }
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        switch mainActionMode {
        case .confirm, .postOptions:
            UIView.animate(withDuration: EditorViewConstants.animationDuration) {
                self.confirmButton.alpha = show ? 1 : 0
            }
        case .post:
            UIView.animate(withDuration: EditorViewConstants.animationDuration) {
                self.postButton.alpha = show ? 1 : 0
                self.postLabel.alpha = show ? 1 : 0
            }
        }
        if showSaveButton {
            UIView.animate(withDuration: EditorViewConstants.animationDuration) {
                self.saveButton.alpha = show ? 1 : 0
            }
        }
    }
    
    /// shows or hides the close button (back caret)
    ///
    /// - Parameter show: true to show, false to hide
    func showCloseButton(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.closeButton.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the canvas for movable views
    ///
    /// - Parameter show: true to show, false to hide
    func showMovableViewCanvas(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.movableViewCanvas.alpha = show ? 1 : 0
        }
    }

    /// shows or hides the tag button
    ///
    /// - Parameter show: true to show, false to hide
    func showTagButton(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.tagButton.alpha = show ? 1 : 0
        }
    }

    func updatePostButton(avatarView: UIView) {
        postButton.addSubview(avatarView)
        postButton.setImage(nil, for: .normal)
        postButton.backgroundColor = KanvasCameraColors.shared.white65
        postButton.clipsToBounds = true
        postButton.layer.cornerRadius = EditorViewConstants.postButtonSize * 0.5
        postButton.layer.borderColor = KanvasCameraColors.shared.white.cgColor
        postButton.layer.borderWidth = CGFloat(2.0)
    }
    
    // MARK: - MovableViewCanvasDelegate
    
    func didTapTextView(options: TextOptions, transformations: ViewTransformations) {
        delegate?.didTapText(options: options, transformations: transformations)
    }

    func didRemoveText() {
        delegate?.didRemoveText()
    }

    func didMoveText() {
        delegate?.didMoveText()
    }
    
    func didRemoveImage(_ imageView: StylableImageView) {
        delegate?.didRemoveImage(imageView)
    }
    
    func didMoveImage(_ imageView: StylableImageView) {
        delegate?.didMoveImage(imageView)
    }
    
    func didBeginTouchesOnMovableView() {
        delegate?.didBeginTouchesOnText()
    }
    
    func didEndTouchesOnMovableView() {
        delegate?.didEndTouchesOnText()
    }
}
