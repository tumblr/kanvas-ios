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
protocol EditorViewDelegate: AnyObject {
    /// Called when the confirm button is pressed
    func didTapConfirmButton()
    /// Called when the close button is pressed
    func didTapCloseButton()
    /// Called when the post button is pressed
    func didTapPostButton()
    /// Called when the save button is pressed
    func didTapSaveButton()
    /// A function that is called when the sound button is pressed
    func didTapMuteButton(enabled: Bool)
    /// Called when the post options button is pressed
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
    /// Obtains the quick post button.
    ///
    /// - Returns: the quick post button.
    func getQuickPostButton() -> UIView
    /// Obtains the blog switcher.
    ///
    /// - Returns: the blog switcher.
    func getBlogSwitcher() -> UIView
}

/// Constants for EditorView
private struct EditorViewConstants {
    static let animationDuration: TimeInterval = 0.25
    static let editionOptionAnimationDuration: TimeInterval = 0.5
    static let editionOptionAnimationBouncingFactor: CGFloat = 1.1
    static let confirmButtonSize: CGFloat = 49
    static let confirmButtonHorizontalMargin: CGFloat = 20
    static let postButtonSize: CGFloat = 54
    static let postButtonHorizontalMargin: CGFloat = 18
    static let postButtonVerticalMargin: CGFloat = Device.belongsToIPhoneXGroup ? 13 : 29
    static let postButtonLabelMargin: CGFloat = 3
    static let muteButtonSize: CGFloat = 50
    static let muteButtonBackgroundColor = UIColor.black.withAlphaComponent(0.49) // Matches the edition option buttons but they include their backgrounds in the asset.
    static let saveButtonSize: CGFloat = 34
    static let saveButtonHorizontalMargin: CGFloat = 20
    static let fakeOptionCellMinSize: CGFloat = KanvasEditorDesign.shared.editorViewFakeOptionCellMinSize
    static let fakeOptionCellMaxSize: CGFloat = KanvasEditorDesign.shared.editorViewFakeOptionCellMaxSize
    
    static let overlayColor: UIColor = KanvasColors.shared.overlayColor.withAlphaComponent(0.87)
    static let overlayLabelMargin: CGFloat = 20
    static let overlayLabelFont: UIFont = .boldSystemFont(ofSize: 16)
    static let overlayLabelTextColor: UIColor = UIColor.white.withAlphaComponent(0.87)
    static let buttonSize: CGFloat = 48
    static let buttonBackgroundColor = UIColor.black.withAlphaComponent(0.4)
    static let buttonTopMargin: CGFloat = KanvasEditorDesign.shared.editorViewButtonTopMargin
    static let buttonBottomMargin: CGFloat = KanvasEditorDesign.shared.editorViewButtonBottomMargin
    static let buttonHorizontalMargin: CGFloat = 16
    static let topElementsInterspace: CGFloat = 8
    static let bottomElementsInterspace: CGFloat = 6
    static let closeButtonSize: CGFloat = KanvasEditorDesign.shared.editorViewCloseButtonSize
    static let closeButtonHorizontalMargin: CGFloat = KanvasEditorDesign.shared.editorViewCloseButtonHorizontalMargin
    
    static let frame: CGRect = .init(x: 0, y: 0, width: EditorViewConstants.postButtonSize, height: EditorViewConstants.postButtonSize)
}

/// A UIView to preview the contents of segments without exporting

final class EditorView: UIView, MovableViewCanvasDelegate, MediaPlayerViewDelegate {

    func didRenderRectChange(rect: CGRect) {
        if playerView?.contentMode != .scaleToFill {
            // When scaling to fill we don't need to update these views as they are already sized correctly.
            drawingCanvasConstraints.update(with: rect)
            movableViewCanvasConstraints.update(with: rect)
        }
        delegate?.didRenderRectChange(rect: rect)
    }

    enum MainActionMode {
        case confirm
        case post
        case postOptions
    }
    
    weak var playerView: MediaPlayerView?

    var exportSize: CGSize {
        let exportView = playerView ?? self
        return CGSize(width: exportView.bounds.width * exportView.contentScaleFactor, height: exportView.bounds.height * exportView.contentScaleFactor)
    }

    private let mainActionMode: MainActionMode
    private let confirmButton = UIButton()
    private let closeButton = UIButton()
    private let saveButton = UIButton()
    private lazy var muteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(weight: .semibold)
        button.setImage(UIImage(systemName: "speaker.2", withConfiguration: configuration), for: .normal)
        button.setImage(UIImage(systemName: "speaker.slash", withConfiguration: configuration), for: .selected)
        return button
    }()
    private let showSaveButton: Bool
    private let showMuteButton: Bool
    private let showCrossIcon: Bool
    private let postButton = UIButton()
    private let postLabel = UILabel()
    private let tagButton = UIButton()
    private let fakeOptionCell = UIImageView()
    private let fakeQuickPostButton = UIImageView()
    private let showCogIcon: Bool
    private let showTagButton: Bool
    private let showTagCollection: Bool
    private let showQuickPostButton: Bool
    private let showBlogSwitcher: Bool
    private let confirmAtTop: Bool
    private let metalContext: MetalContext?
    private let filterSelectionCircle = UIImageView()
    private let navigationContainer = IgnoreTouchesView()
    private let overlay = UIView()
    private let overlayLabel = UILabel()
    private var overlayLabelConstraint: NSLayoutConstraint?
    let collectionContainer = IgnoreTouchesView()
    let filterMenuContainer = IgnoreTouchesView()
    let textMenuContainer = IgnoreTouchesView()
    let drawingMenuContainer = IgnoreTouchesView()
    let gifMakerMenuContainer = IgnoreTouchesView()
    private let quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?
    private let tagCollection: UIView?

    var muteButtonSelected: Bool {
        set {
            muteButton.isSelected = newValue
        }
        get {
            return muteButton.isSelected
        }
    }

    let drawingCanvas = IgnoreTouchesView()

    private lazy var drawingCanvasConstraints: FullViewConstraints = {
        return FullViewConstraints(
            view: drawingCanvas,
            top: drawingCanvas.topAnchor.constraint(equalTo: playerView?.topAnchor ?? topAnchor),
            bottom: drawingCanvas.bottomAnchor.constraint(equalTo: playerView?.bottomAnchor ?? bottomAnchor),
            leading: drawingCanvas.leadingAnchor.constraint(equalTo: playerView?.leadingAnchor ?? leadingAnchor),
            trailing: drawingCanvas.trailingAnchor.constraint(equalTo: playerView?.trailingAnchor ?? trailingAnchor)
        )
    }()

    var movableViewCanvas: MovableViewCanvas

    private lazy var movableViewCanvasConstraints = {
        return FullViewConstraints(
            view: movableViewCanvas,
            top: movableViewCanvas.topAnchor.constraint(equalTo: playerView?.topAnchor ?? topAnchor),
            bottom: movableViewCanvas.bottomAnchor.constraint(equalTo: playerView?.bottomAnchor ?? bottomAnchor),
            leading: movableViewCanvas.leadingAnchor.constraint(equalTo: playerView?.leadingAnchor ?? leadingAnchor),
            trailing: movableViewCanvas.trailingAnchor.constraint(equalTo: playerView?.trailingAnchor ?? trailingAnchor)
        )
    }()

    var avatarView: UIView? {
        return quickBlogSelectorCoordinator?.avatarView(frame: EditorViewConstants.frame)
    }
    
    private lazy var quickPostButton: UIView = {
        guard let delegate = delegate else { return UIView() }
        return delegate.getQuickPostButton()
    }()
    
    private lazy var blogSwitcher: UIView = {
        guard let delegate = delegate else { return UIView() }
        return delegate.getBlogSwitcher()
    }()
    
    private weak var delegate: EditorViewDelegate?
    private var mediaContentMode: UIView.ContentMode
    private var aspectRatio: CGFloat?
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(delegate: EditorViewDelegate?,
         mainActionMode: MainActionMode,
         showSaveButton: Bool,
         showMuteButton: Bool,
         showCrossIcon: Bool,
         showCogIcon: Bool,
         showTagButton: Bool,
         showTagCollection: Bool,
         showQuickPostButton: Bool,
         showBlogSwitcher: Bool,
         confirmAtTop: Bool,
         aspectRatio: CGFloat?,
         quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?,
         tagCollection: UIView?,
         metalContext: MetalContext?,
         mediaContentMode: UIView.ContentMode,
         movableViewCanvas: MovableViewCanvas?) {
        self.delegate = delegate
        self.mainActionMode = mainActionMode
        self.showSaveButton = showSaveButton
        self.showMuteButton = showMuteButton
        self.showCogIcon = showCogIcon
        self.showTagButton = showTagButton
        self.showTagCollection = showTagCollection
        self.showCrossIcon = showCrossIcon
        self.showQuickPostButton = showQuickPostButton
        self.showBlogSwitcher = showBlogSwitcher
        self.confirmAtTop = confirmAtTop
        self.aspectRatio = aspectRatio
        self.quickBlogSelectorCoordinator = quickBlogSelectorCoordinator
        self.tagCollection = tagCollection
        self.metalContext = metalContext
        self.mediaContentMode = mediaContentMode
        self.movableViewCanvas = movableViewCanvas ?? MovableViewCanvas()
        super.init(frame: .zero)
        self.movableViewCanvas.delegate = self
        setupViews()
    }

    func updateUI(forDraggingClip: Bool) {
        if forDraggingClip {
            self.movableViewCanvas.showTrash()
        } else {
            self.movableViewCanvas.hideTrash()
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionContainer.alpha = forDraggingClip ? 0.0 : 1.0
            self.collectionContainer.isHidden = forDraggingClip
        })
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
        if showTagCollection {
            setupTagCollection()
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
        if showMuteButton {
            setupMuteButton()
        }
        setupCollection()
        setupFilterMenu()
        setupTextMenu()
        setupDrawingMenu()
        setupGifMakerMenu()
        setupFakeOptionCell()
        
        if showQuickPostButton {
            setupQuickPostButton()
            setupFakeQuickPostButton()
        }
        if showBlogSwitcher {
            setupBlogSwitcher()
        }
        
        setupOverlay()
        setupOverlayLabel()
    }

    // MARK: - views

    private func setupPlayer() {
        let playerView = MediaPlayerView(metalContext: metalContext, mediaContentMode: mediaContentMode)
        playerView.delegate = self

        if let aspectRatio = aspectRatio {
            playerView.layer.masksToBounds = true
            playerView.layer.cornerRadius = 12
            playerView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(playerView)

            let bottomConstraint: NSLayoutConstraint
            let topConstraint: NSLayoutConstraint
            if Device.belongsToIPhoneXGroup || Device.isIPad {
                bottomConstraint = playerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
                topConstraint = playerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
            } else {
                bottomConstraint = playerView.bottomAnchor.constraint(equalTo: bottomAnchor)
                topConstraint = playerView.topAnchor.constraint(equalTo: topAnchor)
            }
            NSLayoutConstraint.activate([
                playerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                playerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
                playerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
                playerView.widthAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: aspectRatio, constant: 0),
                topConstraint,
                bottomConstraint,
                playerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
            ])
        } else {
            playerView.add(into: self)
        }

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
        tagButton.setImage(KanvasImages.tagImage, for: .normal)
        tagButton.backgroundColor = EditorViewConstants.buttonBackgroundColor
        tagButton.layer.cornerRadius = EditorViewConstants.buttonSize / 2
        tagButton.layer.masksToBounds = true
        navigationContainer.addSubview(tagButton)

        tagButton.addTarget(self, action: #selector(tagButtonPressed), for: .touchUpInside)
        tagButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagButton.leadingAnchor.constraint(equalTo: navigationContainer.leadingAnchor, constant: EditorViewConstants.buttonHorizontalMargin),
            tagButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -EditorViewConstants.buttonBottomMargin),
            tagButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.buttonSize),
            tagButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.buttonSize)
        ])
    }
    
    private func setupTagCollection() {
        guard let tagCollection = tagCollection else { return }
        tagCollection.accessibilityLabel = "Tag Collection"
        navigationContainer.addSubview(tagCollection)

        tagCollection.translatesAutoresizingMaskIntoConstraints = false
        let horizontalMargin = EditorViewConstants.buttonHorizontalMargin + EditorViewConstants.buttonSize + EditorViewConstants.bottomElementsInterspace
        NSLayoutConstraint.activate([
            tagCollection.leadingAnchor.constraint(equalTo: navigationContainer.leadingAnchor, constant: horizontalMargin),
            tagCollection.trailingAnchor.constraint(equalTo: navigationContainer.trailingAnchor, constant: -horizontalMargin),
            tagCollection.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -EditorViewConstants.buttonBottomMargin),
            tagCollection.heightAnchor.constraint(equalToConstant: EditorViewConstants.buttonSize),
        ])
    }
    
    private func setupCloseButton() {
        navigationContainer.addSubview(closeButton)
        closeButton.accessibilityLabel = "Close Button"
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        if KanvasEditorDesign.shared.isVerticalMenu {
            closeButton.backgroundColor = EditorViewConstants.buttonBackgroundColor
            closeButton.layer.cornerRadius = EditorViewConstants.buttonSize / 2
            closeButton.layer.masksToBounds = true
        }
        else {
            closeButton.layer.applyShadows()
            closeButton.imageView?.contentMode = .scaleAspectFit
        }
        
        let image = showCrossIcon ? KanvasEditorDesign.shared.editorViewCloseImage : KanvasEditorDesign.shared.editorViewBackImage
        closeButton.setImage(image, for: .normal)
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor, constant: EditorViewConstants.closeButtonHorizontalMargin),
            closeButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: EditorViewConstants.buttonTopMargin),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.closeButtonSize)
        ])
    }
    
    private func setupConfirmButton() {
        confirmButton.accessibilityLabel = "Confirm Button"
        navigationContainer.addSubview(confirmButton)
        confirmButton.setImage(KanvasImages.shared.nextImage, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        let positioningConstraints: [NSLayoutConstraint]
        if confirmAtTop {
            positioningConstraints = [
                confirmButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -EditorViewConstants.confirmButtonHorizontalMargin),
                confirmButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
            ]
        } else {
            positioningConstraints = [
                confirmButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -EditorViewConstants.confirmButtonHorizontalMargin),
                confirmButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -EditorViewConstants.buttonBottomMargin)
            ]
        }

        NSLayoutConstraint.activate([
            confirmButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
        ] + positioningConstraints)
    }

    private func setupPostOptionsButton() {
        confirmButton.accessibilityLabel = "Post Options Button"
        navigationContainer.addSubview(confirmButton)
        confirmButton.addTarget(self, action: #selector(postOptionsButtonPressed), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        if showCogIcon {
            confirmButton.backgroundColor = EditorViewConstants.buttonBackgroundColor
            confirmButton.setImage(KanvasImages.cogImage, for: .normal)
            confirmButton.layer.cornerRadius = EditorViewConstants.confirmButtonSize / 2
            confirmButton.layer.masksToBounds = true
            
            NSLayoutConstraint.activate([
                confirmButton.trailingAnchor.constraint(equalTo: navigationContainer.trailingAnchor, constant: -EditorViewConstants.buttonHorizontalMargin),
                confirmButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
                confirmButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
                confirmButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -EditorViewConstants.buttonBottomMargin)
            ])
        }
        else {
            confirmButton.setImage(KanvasImages.shared.nextImage, for: .normal)
            
            NSLayoutConstraint.activate([
                confirmButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -EditorViewConstants.confirmButtonHorizontalMargin),
                confirmButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
                confirmButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
                confirmButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -EditorViewConstants.buttonBottomMargin)
            ])
        }
    }
    
    private func setupCollection() {
        navigationContainer.addSubview(collectionContainer)
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Edition Menu Collection Container"
        collectionContainer.clipsToBounds = false
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        if KanvasEditorDesign.shared.isVerticalMenu {
            
            NSLayoutConstraint.activate([
                collectionContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                collectionContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                collectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                collectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            ])
        }
        else {

            let leftButton: UIView?
            let leadingMargin: CGFloat
            let xAnchor: NSLayoutXAxisAnchor
            let trailingMargin: CGFloat

            if showMuteButton {
                leftButton = muteButton
                leadingMargin = EditorViewConstants.saveButtonHorizontalMargin
            } else {
                leftButton = nil
                leadingMargin = 0
            }

            if confirmAtTop {
                xAnchor = safeAreaLayoutGuide.trailingAnchor
                trailingMargin = 0
            } else {
                if showSaveButton {
                    xAnchor = saveButton.leadingAnchor
                    trailingMargin = EditorViewConstants.saveButtonHorizontalMargin
                }
                else {
                    xAnchor = confirmOrPostButton().leadingAnchor
                    trailingMargin = confirmOrPostButtonHorizontalMargin()
                }
            }

            let verticalPositioning: [NSLayoutConstraint]
            if confirmAtTop {
                verticalPositioning = [collectionContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -KanvasEditorDesign.shared.editorViewButtonBottomMargin)]
            } else {
                verticalPositioning = [collectionContainer.centerYAnchor.constraint(equalTo: confirmOrPostButton().centerYAnchor)]
            }

            let leftButtonConstraints = [
                leftButton?.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor)
            ].compactMap { $0 }

            NSLayoutConstraint.activate([
                collectionContainer.leadingAnchor.constraint(equalTo: leftButton?.trailingAnchor ?? safeAreaLayoutGuide.leadingAnchor, constant: leadingMargin),
                collectionContainer.trailingAnchor.constraint(equalTo: xAnchor, constant: -trailingMargin / 2),
                collectionContainer.heightAnchor.constraint(equalToConstant: EditionMenuCollectionView.height),
            ] + verticalPositioning + leftButtonConstraints)
        }
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
            textMenuContainer.leadingAnchor.constraint(equalTo: playerView?.leadingAnchor ?? leadingAnchor),
            textMenuContainer.trailingAnchor.constraint(equalTo: playerView?.trailingAnchor ?? trailingAnchor),
            textMenuContainer.topAnchor.constraint(equalTo: playerView?.topAnchor ?? topAnchor),
            textMenuContainer.bottomAnchor.constraint(equalTo: playerView?.bottomAnchor ?? bottomAnchor)
        ])
    }
    
    private func setupDrawingMenu() {
        drawingMenuContainer.backgroundColor = .clear
        drawingMenuContainer.accessibilityIdentifier = "Drawing Menu Container"
        drawingMenuContainer.clipsToBounds = false
        
        addSubview(drawingMenuContainer)
        drawingMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawingMenuContainer.leadingAnchor.constraint(equalTo: playerView?.leadingAnchor ?? leadingAnchor),
            drawingMenuContainer.trailingAnchor.constraint(equalTo: playerView?.trailingAnchor ?? trailingAnchor),
            drawingMenuContainer.topAnchor.constraint(equalTo: playerView?.topAnchor ?? topAnchor),
            drawingMenuContainer.bottomAnchor.constraint(equalTo: playerView?.bottomAnchor ?? bottomAnchor)
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
        fakeOptionCell.contentMode = .center
        fakeOptionCell.layer.cornerRadius = EditorViewConstants.fakeOptionCellMaxSize / 2
        fakeOptionCell.layer.masksToBounds = true
        
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
    
    /// Sets up the image used for the animation that transforms the quick post button into a confirm button
    private func setupFakeQuickPostButton() {
        fakeQuickPostButton.accessibilityLabel = "Fake Quick Post Button"
        
        addSubview(fakeQuickPostButton)
        fakeQuickPostButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fakeQuickPostButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: EditorViewConstants.buttonTopMargin),
            fakeQuickPostButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -EditorViewConstants.buttonHorizontalMargin),
            fakeQuickPostButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.buttonSize),
        ])
        
        fakeQuickPostButton.alpha = 0
    }

    @objc func nextPressed() {
        delegate?.didTapPostButton()
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
            postButton.setImage(KanvasImages.shared.nextImage, for: .normal)
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
        postLabel.font = KanvasFonts.shared.postLabelFont
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
        saveButton.setImage(KanvasImages.saveImage, for: .normal)
        saveButton.imageView?.tintColor = .white
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            saveButton.centerYAnchor.constraint(equalTo: confirmOrPostButton().centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: confirmOrPostButton().leadingAnchor, constant: -EditorViewConstants.saveButtonHorizontalMargin),
            saveButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.saveButtonSize),
            saveButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.saveButtonSize)
        ])
    }

    func setupMuteButton() {
        muteButton.accessibilityLabel = "Sound Button"
        navigationContainer.addSubview(muteButton)
        muteButton.tintColor = .white
        muteButton.layer.applyShadows()
        muteButton.addTarget(self, action: #selector(muteButtonPressed), for: .touchUpInside)

        muteButton.backgroundColor = EditorViewConstants.muteButtonBackgroundColor
        muteButton.layer.cornerRadius = EditorViewConstants.muteButtonSize/2
        muteButton.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            muteButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: EditorViewConstants.saveButtonHorizontalMargin),
            muteButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.muteButtonSize),
            muteButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.muteButtonSize),
        ])
    }

    func confirmOrPostButton() -> UIView {
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
    
    private func setupOverlay() {
        overlay.accessibilityLabel = "Overlay"
        overlay.backgroundColor = EditorViewConstants.overlayColor
        overlay.alpha = 0
        
        addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func setupOverlayLabel() {
        overlayLabel.accessibilityLabel = "Overlay Label"
        overlay.addSubview(overlayLabel)
        overlayLabel.textColor = EditorViewConstants.overlayLabelTextColor
        overlayLabel.font = EditorViewConstants.overlayLabelFont
        overlayLabel.textAlignment = .right
        
        overlayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYOffset = EditorViewConstants.buttonTopMargin + EditorViewConstants.buttonSize / 2
        NSLayoutConstraint.activate([
            overlayLabel.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: centerYOffset),
            overlayLabel.leadingAnchor.constraint(equalTo: overlay.leadingAnchor),
        ])
    }
    
    private func setupQuickPostButton() {
        quickPostButton.accessibilityLabel = "Quick Post Button"
        
        addSubview(quickPostButton)
        quickPostButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            quickPostButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: EditorViewConstants.buttonTopMargin),
            quickPostButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -EditorViewConstants.buttonHorizontalMargin),
            quickPostButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.buttonSize),
        ])
    }
    
    private func setupBlogSwitcher() {
        accessibilityLabel = "Blog Switcher"
        addSubview(blogSwitcher)
        blogSwitcher.translatesAutoresizingMaskIntoConstraints = false
        
        let trailingAnchor: NSLayoutConstraint
        if quickPostButton.isDescendant(of: self) {
            trailingAnchor = blogSwitcher.trailingAnchor.constraint(equalTo: quickPostButton.leadingAnchor, constant: -EditorViewConstants.topElementsInterspace)
        }
        else {
            trailingAnchor = blogSwitcher.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -EditorViewConstants.buttonHorizontalMargin)
        }
        
        NSLayoutConstraint.activate([
            trailingAnchor,
            blogSwitcher.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: EditorViewConstants.buttonTopMargin),
            blogSwitcher.heightAnchor.constraint(equalToConstant: EditorViewConstants.buttonSize),
            blogSwitcher.widthAnchor.constraint(equalToConstant: EditorViewConstants.buttonSize),
        ])
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

    @objc private func muteButtonPressed() {
        muteButton.isSelected = !muteButton.isSelected
        delegate?.didTapMuteButton(enabled: muteButton.isSelected)
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
    
    /// shows or hides the navigation container, quick post button and blog switcher
    ///
    /// - Parameter show: true to show, false to hide
    func showNavigationItems(_ show: Bool) {
        showNavigationContainer(show)
        showQuickPostButton(show)
        showBlogSwitcher(show)
    }
    
    /// shows or hides the navigation container
    ///
    /// - Parameter show: true to show, false to hide
    func showNavigationContainer(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.navigationContainer.alpha = show ? 1 : 0
            self.blogSwitcher.alpha = self.showBlogSwitcher && show ? 1 : 0
            self.quickPostButton.alpha = self.showQuickPostButton && show ? 1 : 0
        }
    }
    
    /// shows or hides the quick post button
    ///
    /// - Parameter show: true to show, false to hide
    func showQuickPostButton(_ show: Bool, animated: Bool = true) {
        let action: () -> Void = {
            self.quickPostButton.alpha = self.showQuickPostButton && show ? 1 : 0
        }
        
        if animated {
            UIView.animate(withDuration: EditorViewConstants.animationDuration, animations: action)
        }
        else {
            action()
        }
    }
    
    /// shows or hides the blog switcher
    ///
    /// - Parameter show: true to show, false to hide
    func showBlogSwitcher(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.blogSwitcher.alpha = self.showBlogSwitcher && show ? 1 : 0
        }
    }
    
    /// animates the transition between the main editor tools and a specific menu
    ///
    /// - Parameters
    ///   - cell: the cell of the edition option
    ///   - finalLocation: the location where animation will end
    ///   - completion: a closure to execute when the animation ends
    func animateEditionOption(cell: KanvasEditorMenuCollectionCell?, finalLocation: CGPoint, completion: @escaping (Bool) -> Void) {
        if KanvasEditorDesign.shared.isVerticalMenu {
            animateFakeCellPop(cell: cell, finalLocation: finalLocation, completion: completion)
        }
        else {
            animateFakeCellTranslation(cell: cell, finalLocation: finalLocation, completion: completion)
        }
    }
    
    /// animates the transition between a specific menu and the main editor tools
    ///
    /// - Parameters
    ///   - cell: the cell of the edition option
    ///   - initialLocation: the location where the checkmark button starts the animation
    func animateReturnOfEditionOption(cell: KanvasEditorMenuCollectionCell?, initialLocation: CGPoint) {
        if KanvasEditorDesign.shared.isVerticalMenu {
            animateFakeCellPopBackwards(cell: cell, initialLocation: initialLocation)
        }
        else {
            animateFakeCellTranslationBackwards(cell: cell, initialLocation: initialLocation)
        }
    }
    
    /// animates the transition between the main editor tools and a specific menu with a pop-out effect.
    ///
    /// - Parameters
    ///   - cell: the cell of the edition option
    ///   - finalLocation: the location where animation will end
    ///   - completion: a closure to execute when the animation ends
    private func animateFakeCellPop(cell: KanvasEditorMenuCollectionCell?, finalLocation: CGPoint, completion: @escaping (Bool) -> Void) {
        let distance = finalLocation - fakeOptionCell.center
        let translationTransform = CGAffineTransform(translationX: distance.x, y: distance.y)
        
        fakeOptionCell.image = KanvasEditorDesign.shared.checkmarkImage
        fakeOptionCell.backgroundColor = KanvasColors.shared.primaryButtonBackgroundColor
        fakeOptionCell.alpha = 1
        fakeOptionCell.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(translationTransform)
        fakeQuickPostButton.image = quickPostButton.asImage()
        fakeQuickPostButton.alpha = 1
        quickPostButton.isHidden = true
        
        let duration = EditorViewConstants.editionOptionAnimationDuration
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.05 / duration, animations: {
                let scale = EditorViewConstants.editionOptionAnimationBouncingFactor
                self.fakeQuickPostButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.05 / duration, relativeDuration: 0.2 / duration, animations: {
                self.fakeQuickPostButton.transform = CGAffineTransform(scaleX: 0, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.25 / duration, relativeDuration: 0.2 / duration, animations: {
                let scale = EditorViewConstants.editionOptionAnimationBouncingFactor * EditorViewConstants.fakeOptionCellMinSize / EditorViewConstants.fakeOptionCellMaxSize
                self.fakeOptionCell.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(translationTransform)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.45 / duration, relativeDuration: 0.05 / duration, animations: {
                let scale = EditorViewConstants.fakeOptionCellMinSize / EditorViewConstants.fakeOptionCellMaxSize
                self.fakeOptionCell.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(translationTransform)
            })
        }, completion: { _ in
            completion(true)
            self.fakeOptionCell.alpha = 0
            self.fakeQuickPostButton.alpha = 0
        })
    }
    
    /// animates the transition between a specific menu and the main editor tools with a pop-out effect.
    ///
    /// - Parameters
    ///   - cell: the cell of the edition option
    ///   - initialLocation: the location where the checkmark button starts the animation
    private func animateFakeCellPopBackwards(cell: KanvasEditorMenuCollectionCell?, initialLocation: CGPoint) {
        let distance = initialLocation - fakeOptionCell.center
        let translationTransform = CGAffineTransform(translationX: distance.x, y: distance.y)
        
        fakeOptionCell.image = KanvasEditorDesign.shared.checkmarkImage
        fakeOptionCell.backgroundColor = KanvasColors.shared.primaryButtonBackgroundColor
        fakeOptionCell.alpha = 1
        fakeOptionCell.transform = translationTransform
        fakeQuickPostButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        fakeQuickPostButton.alpha = 1
        
        // Necessary to get the image of the button
        quickPostButton.isHidden = false
        fakeQuickPostButton.image = quickPostButton.asImage()
        quickPostButton.isHidden = true
        
        
        let duration = EditorViewConstants.editionOptionAnimationDuration
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.05 / duration, animations: {
                let scale = EditorViewConstants.editionOptionAnimationBouncingFactor * EditorViewConstants.fakeOptionCellMinSize / EditorViewConstants.fakeOptionCellMaxSize
                self.fakeOptionCell.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(translationTransform)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.05 / duration, relativeDuration: 0.2 / duration, animations: {
                self.fakeOptionCell.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(translationTransform)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.25 / duration, relativeDuration: 0.2 / duration, animations: {
                let scale = EditorViewConstants.editionOptionAnimationBouncingFactor
                self.fakeQuickPostButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.45 / duration, relativeDuration: 0.05 / duration, animations: {
                self.fakeQuickPostButton.transform = .identity
            })
        }, completion: { _ in
            self.fakeOptionCell.alpha = 0
            self.fakeQuickPostButton.alpha = 0
            self.quickPostButton.isHidden = false
        })
    }
    
    /// animates the transition between the main editor tools and a specific menu with a translation effect.
    ///
    /// - Parameters
    ///   - cell: the cell of the edition option
    ///   - finalLocation: the location where animation will end
    ///   - completion: a closure to execute when the animation ends
    private func animateFakeCellTranslation(cell: KanvasEditorMenuCollectionCell?, finalLocation: CGPoint, completion: @escaping (Bool) -> Void) {
        guard let cell = cell, let cellParent = cell.superview else {
            completion(false)
            return
        }
        fakeOptionCell.center = cellParent.convert(cell.center, to: nil)
        fakeOptionCell.image = cell.iconView.image
        fakeOptionCell.backgroundColor = cell.iconView.backgroundColor
        fakeOptionCell.alpha = 1
        cell.alpha = 0
        
        let duration = EditorViewConstants.editionOptionAnimationDuration
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45 / duration, animations: {
                self.fakeOptionCell.image = KanvasEditorDesign.shared.checkmarkImage
                self.fakeOptionCell.backgroundColor = KanvasColors.shared.primaryButtonBackgroundColor
                let scale = EditorViewConstants.fakeOptionCellMinSize / EditorViewConstants.fakeOptionCellMaxSize
                self.fakeOptionCell.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.fakeOptionCell.center = finalLocation
            })
        }, completion: { _ in
            self.fakeOptionCell.alpha = 0
            completion(true)
        })
    }
    
    /// animates the transition between a specific menu and the main editor tools with a translation effect.
    ///
    /// - Parameters
    ///   - cell: the cell of the edition option
    ///   - initialLocation: the location where the checkmark button starts the animation
    private func animateFakeCellTranslationBackwards(cell: KanvasEditorMenuCollectionCell?, initialLocation: CGPoint) {
        guard let cell = cell, let cellParent = cell.superview else { return }
        fakeOptionCell.center = initialLocation
        fakeOptionCell.alpha = 1
        
        let duration = EditorViewConstants.editionOptionAnimationDuration
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45 / duration, animations: {
                self.fakeOptionCell.image = cell.iconView.image
                self.fakeOptionCell.backgroundColor = cell.iconView.backgroundColor
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
    
    /// shows or hides the tag collection
    ///
    /// - Parameter show: true to show, false to hide
    func showTagCollection(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.tagCollection?.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the overlay
    ///
    /// - Parameters
    ///  -  show: true to show, false to hide
    ///  - completion: an optional action to be executed when the animation ends
    func showOverlay(_ show: Bool, completion: ((Bool) -> Void)? = nil) {
        overlayLabel.alpha = show ? 1 : 0
        UIView.animate(withDuration: EditorViewConstants.animationDuration, animations: { [weak self] in
            self?.overlay.alpha = show ? 1 : 0
        }, completion: completion)
    }
    
    /// moves the overlay label next to a specified view.
    ///
    /// - Parameter view: the view next to the label.
    func moveOverlayLabel(to view: UIView) {
        overlayLabelConstraint?.isActive = false
        let newConstraint = overlayLabel.trailingAnchor.constraint(equalTo: view.leadingAnchor,
                                                                   constant: -EditorViewConstants.overlayLabelMargin)
        newConstraint.isActive = true
        overlayLabelConstraint = newConstraint
        layoutIfNeeded()
    }
    
    /// Moves a view to be shown above the overlay.
    ///
    /// - Parameters
    ///  - view: the view that will be moved.
    ///  - visible: true to move the specified view to the front. false to move the overlay to the front.
    func moveViewToFront(_ view: UIView, visible: Bool) {
        if visible {
            bringSubviewToFront(view)
        }
        else {
            bringSubviewToFront(overlay)
        }
    }
    /// Modifies the overlay message.
    ///
    /// - Parameter text: the new message.
    func setOverlayLabel(text: String?) {
        let newText = text ?? ""
        let animation: () -> Void = { [weak self] in
            self?.overlayLabel.text = newText
        }
        
        UIView.transition(with: overlayLabel, duration: EditorViewConstants.animationDuration,
                          options: .transitionCrossDissolve, animations: animation, completion: nil)
    }

    func updatePostButton(avatarView: UIView) {
        postButton.addSubview(avatarView)
        postButton.setImage(nil, for: .normal)
        postButton.backgroundColor = KanvasColors.shared.white65
        postButton.clipsToBounds = true
        postButton.layer.cornerRadius = EditorViewConstants.postButtonSize * 0.5
        postButton.layer.borderColor = KanvasColors.shared.white.cgColor
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
