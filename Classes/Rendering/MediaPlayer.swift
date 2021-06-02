//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import CoreMedia
import AVFoundation
import VideoToolbox
import OpenGLES
import GLKit
import CoreImage

/// Delegate for MediaPlayer
protocol MediaPlayerDelegate: class {
    /// Called then the first pixel buffer is shown
    /// - Parameter image: the first frame shown
    func didDisplayFirstFrame(_ image: UIImage)

    func getDefaultTimeIntervalForImageSegments() -> TimeInterval
}

/// Delegate for MediaPlayerView
protocol MediaPlayerViewDelegate: class {
    /// Called when the rendering rectangle changes
    /// - Parameter rect: new rendering rectangle
    func didRenderRectChange(rect: CGRect)
}

/// Types of media the player can play.
enum MediaPlayerContent {
    case image(UIImage, TimeInterval?)
    case video(URL)
}

enum MediaPlayerPlaybackMode {
    case loop, rebound, reverse

    init(from playbackOption: PlaybackOption) {
        switch playbackOption {
        case .loop:
            self = .loop
        case .rebound:
            self = .rebound
        case .reverse:
            self = .reverse
        }
    }
}

/// View for rendering the player.
final class MediaPlayerView: UIView, GLPixelBufferViewDelegate, UIGestureRecognizerDelegate {

    weak var renderer: Rendering?

    weak var pixelBufferView: PixelBufferView?

    weak var backgroundView: UIImageView?

    weak var delegate: MediaPlayerViewDelegate?

    var mediaTransform: GLKMatrix4? {
         didSet {
            let transform = GLKMatrix4Translate(mediaTransform ?? GLKMatrix4Identity, 0, -300, 0)
            pixelBufferView?.mediaTransform = transform
         }
     }

    var viewportTransform: CGAffineTransform? {
        set {
            renderer?.viewportTransform = newValue ?? .identity
        }
        get {
            return renderer?.viewportTransform
        }
    }

    var isPortrait: Bool = true {
        didSet {
            pixelBufferView?.isPortrait = isPortrait
        }
    }

    var refreshHandler: (() -> Void)?

    init(metalContext: MetalContext?, mediaContentMode: UIView.ContentMode) {
        super.init(frame: .zero)

        let pixelBufferView: PixelBufferView & UIView

        if let metalContext = metalContext {
            pixelBufferView = MetalPixelBufferView()
        }
        else {
            pixelBufferView = GLPixelBufferView(delegate: self, mediaContentMode: mediaContentMode)
        }
        pixelBufferView.add(into: self)
        self.pixelBufferView = pixelBufferView
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView = imageView
        self.insertSubview(imageView, belowSubview: pixelBufferView)
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: pixelBufferView.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: pixelBufferView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: pixelBufferView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: pixelBufferView.bottomAnchor)
        ])
        addGestureHandlers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - GLPixelBufferViewDelegate

    func didRenderRectChange(rect: CGRect) {
        delegate?.didRenderRectChange(rect: rect)
    }

    func addGestureHandlers() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGestureRecognizer(gestureRecognizer:)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        pan.delaysTouchesBegan = false
        pan.name = "Kanvas Pan+Zoom Pan"
        addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleGestureRecognizer(gestureRecognizer:)))
        pinch.delegate = self
        pinch.delaysTouchesBegan = false
        pinch.name = "Kanvas Pan+Zoom Pinch"
        addGestureRecognizer(pinch)

//        let rotation = UIRotationGestureRecognizer
    }

    var currentSize: CGSize = .zero
    var initialPoint = CGPoint()
    var currentPoint: CGPoint?
    var currentScale: CGFloat = 1

    var currentScaleTransform: CGAffineTransform = .identity
    var currentTranslationTransform: CGAffineTransform = .identity

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == self {
            return true
        } else {
            return false
        }
    }

    @objc func handleGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        let minScale = bounds.width / currentSize.width
        switch gestureRecognizer {
        case let pan as UIPanGestureRecognizer:
            // Get the changes in the X and Y directions relative to
            // the superview's coordinate space.
            let translation = pan.translation(in: self.superview)

            switch gestureRecognizer.state {
            case .ended:
                let velocity = pan.velocity(in: self.superview)
                currentPoint = CGPoint(x: initialPoint.x + translation.x + velocity.x , y: initialPoint.y + translation.y + velocity.y)
                self.initialPoint = currentPoint ?? initialPoint
            default:
                currentPoint = CGPoint(x: initialPoint.x + translation.x , y: initialPoint.y + translation.y)
                let transform = mediaTransform ?? GLKMatrix4Identity
                currentTranslationTransform = CGAffineTransform(translationX: currentPoint?.x ?? 0, y: currentPoint?.y ?? 0)
            }
            print("Transform: \(translation.x) \(translation.y)")
        case let pinch as UIPinchGestureRecognizer:
//            print("Handle pinch: \(pinch.scale) - \(pinch.state.rawValue)")
            let scale = pinch.scale
            let finalScale: CGFloat
            switch gestureRecognizer.state {
            case .ended:
                var newScale = currentScale * scale
                if newScale < minScale {
                    newScale = minScale
                } else {
                    newScale = currentScale * scale
                }
                finalScale = newScale
                currentScale = newScale
            case .began:
                finalScale = currentScale * scale
                let touch1 = pinch.location(ofTouch: 0, in: self)
                let touch2 = pinch.location(ofTouch: 1, in: self)
                let touchRect = CGRect(x: min(touch1.x, touch2.x), y: min(touch1.y, touch2.y), width: max(touch1.x, touch2.x), height: max(touch1.y, touch2.y))
                let center = CGPoint(x: touchRect.midX, y: touchRect.midY)
                currentPoint = center
            default:
                finalScale = currentScale * scale
            }

            currentScaleTransform = CGAffineTransform(scaleX: finalScale, y: finalScale)
            let newSize = currentSize.applying(currentScaleTransform)
            currentTranslationTransform = translation(center: currentPoint ?? .zero, newSize: newSize)
        default:
            break
        }
        renderer?.viewportTransform = currentTranslationTransform.concatenating(currentScaleTransform).concatenating(currentTranslationTransform.inverted())
        refreshHandler?()
    }

    private func centerOffset(center: CGPoint, size: CGSize, newSize: CGSize) -> (CGFloat, CGFloat) {
//        print("Frame Width: \(bounds.size.width) Frame Height: \(bounds.size.height)")
//        print("Media Width: \(size.width) Media Height: \(size.height)")

//        let xOffset = (size.width - newSize.width) / 2
//        let yOffset = (size.height - newSize.height) / 2


        let xOffset = center.x - size.width
        let yOffset = center.y - size.height

//        CGFloat scale = pinch.scale;
//        transform = CGAffineTransformScale(transform, scale, scale);
//        transform = CGAffineTransformTranslate(transform, -pinchCenter.x, -pinchCenter.y);
//        pinchView.transform = transform;
//        pinch.scale = 1.0;


//        let xOffset = (size.width - center.x * 2)
//        let yOffset = (size.height - center.y * 2)

        return (xOffset, yOffset)
    }

    private func translation(center: CGPoint, newSize: CGSize) -> CGAffineTransform {
        let (x, y) = centerOffset(center: center, size: self.bounds.size, newSize: newSize)
        return CGAffineTransform(translationX: x, y: y)
    }
}

/// Controls the playback of many MediaPlayerContent
final class MediaPlayer {

    private enum MediaPlayerContentLoaded {
        case image(UIImage, CMSampleBuffer, TimeInterval?)
        case video(URL, AVPlayerItem, AVPlayerItemVideoOutput)

        var sampleBuffer: CMSampleBuffer? {
            switch self {
            case .image(_, let sampleBuffer, _):
                return sampleBuffer
            default:
                return nil
            }
        }

        var asset: AVAsset? {
            switch self {
            case .video(let url, _, _):
                return AVAsset(url: url)
            default:
                return nil
            }
        }

        var playerItem: AVPlayerItem? {
            switch self {
            case .video(_, let playerItem, _):
                return playerItem
            default:
                return nil
            }
        }

        var playerItemVideoOutput: AVPlayerItemVideoOutput? {
            switch self {
            case .video(_, _, let playerItemVideoOutput):
                return playerItemVideoOutput
            default:
                return nil
            }
        }

        var interval: TimeInterval? {
            switch self {
            case .image(_, _, let interval):
                return interval
            case .video(_, _, _):
                return .zero
            }
        }
    }

    weak var delegate: MediaPlayerDelegate?

    /// The Rendering instance for the player.
    let renderer: Rendering

    /// The MediaPlayerView that this controls.
    weak var playerView: MediaPlayerView? {
        didSet {
            playerView?.renderer = renderer
        }
    }

    /// The last timestamp a still photo has a filter applied. This is used to replicate the filter when exporting an image.
    var lastStillFilterTime: TimeInterval = 0
    
    private var playableMedia: [MediaPlayerContentLoaded] = []
    private var currentlyPlayingMediaIndex: Int = -1
    private var currentlyPlayingMedia: MediaPlayerContentLoaded? {
        guard currentlyPlayingMediaIndex >= 0 && currentlyPlayingMediaIndex < playableMedia.count else {
            return nil
        }
        return playableMedia[currentlyPlayingMediaIndex]
    }
    private var nextImageTimer: Timer?
    private var displayLink: CADisplayLink?
    private var currentPixelBuffer: CVPixelBuffer?
    private var firstFrameSent = false
    private var startTime: TimeInterval = Date.timeIntervalSinceReferenceDate
    private lazy var avPlayer: AVPlayer = {
        let player = AVPlayer(playerItem: nil)
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self, selector: #selector(videoFailedToPlayToEndTime), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        return player
    }()

    var rate: Float = 1.0
    var startMediaIndex: Int = -1
    var endMediaIndex: Int = -1

    private var playSingleFrameAtIndex: Int? = nil
    private var playbackDirection: Int = 1

    var playbackMode: MediaPlayerPlaybackMode = .loop {
        didSet {
            switch playbackMode {
            case .loop:
                self.playbackDirection = 1
            case .reverse:
                self.playbackDirection = -1
            case .rebound:
                break
            }
        }
    }


    /// Default initializer
    /// - Parameter renderer: Rendering instance for this player to use.
    init(renderer: Rendering?) {
        self.renderer = renderer ?? Renderer()
        self.renderer.delegate = self
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch let error {
            print("Failed to set audio session category: \(error)")
        }
    }

    deinit {
        stop()
    }

    // MARK: - Public API

    /// The filter type for the player to use to process frames with
    var filterType: FilterType? {
        get {
            return renderer.filterType
        }
        set {
            renderer.filterType = newValue ?? .passthrough
            renderer.refreshFilter()
            refreshMediaAfterFilterChange()
        }
    }

    /// Plays a list of media repeatidly.
    /// - Parameter media: the list of media to play
    func play(media: [MediaPlayerContent]) {
        guard media.count > 0 else {
            return
        }
        currentlyPlayingMediaIndex = -1
        loadAll(media: media)
        playNextMedia()
        playerView?.refreshHandler = { [weak self] in
            self?.playCurrentMedia()
        }
    }

    /// Stops the playback of media
    func stop() {
        pause()
        currentlyPlayingMediaIndex = -1
        rate = 1
        startMediaIndex = -1
        endMediaIndex = -1
        playbackDirection = 1
        playableMedia.removeAll()
    }

    /// Pauses the playback of media.
    func pause() {
        displayLink?.invalidate()
        displayLink = nil
        nextImageTimer?.invalidate()
        nextImageTimer = nil
        avPlayer.pause()
        renderer.reset()
    }

    var isMuted: Bool {
        set {
            avPlayer.isMuted = newValue
        }
        get {
            return avPlayer.isMuted
        }
    }

    /// Resumes the playback of media.
    /// Can be used to resume playback after a call to `pause`.
    /// This currently just resumes at the current segment; it doesn't continue playing a video at the time it was paused.
    func resume() {
        playCurrentMedia()
    }
    
    /// Plays a single frame at a specific location
    /// Useful for displaying a frame while scrubbing/trimming
    /// - Parameter at: Value between 0 and 1, where 0 is the first frame, and 1 is the last frame.
    func playSingleFrame(at location: CGFloat) {
        var index = Int(CGFloat(playableMedia.count) * location)
        if index > playableMedia.count - 1 {
            index = playableMedia.count - 1
        }
        else if index < 0 {
            index = 0
        }
        playSingleFrameAtIndex = index
    }

    /// Cancels the single-frame playback, resuming the playback before playSingleFrame was called.
    func cancelPlayingSingleFrame() {
        playSingleFrameAtIndex = nil
    }

    /// Obtains color from a pixel
    /// - Parameter point: the point to take the color from
    func getColor(from point: CGPoint) -> UIColor {
        guard let pixelBuffer: CVPixelBuffer = currentPixelBuffer,
        let playerView = playerView,
        playerView.frame.contains(point) else { return .black }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let int32Buffer = unsafeBitCast(CVPixelBufferGetBaseAddress(pixelBuffer), to: UnsafeMutablePointer<UInt32>.self)
        let int32PerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let bufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let bufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let heightFactor = 4
        
        let bufferAspectRatio = bufferWidth.f / bufferHeight.f
        let screenAspectRatio = Device.screenWidth.f / Device.screenHeight.f
        
        let x,y: CGFloat
        
        if bufferAspectRatio > screenAspectRatio {
            let croppedSpace = bufferWidth - (CGFloat(Device.screenWidth) * bufferHeight / CGFloat(Device.screenHeight))
            let visibleBufferWidth = bufferWidth - croppedSpace
            x = croppedSpace / 2 + point.x * visibleBufferWidth / CGFloat(Device.screenWidth)
            y = point.y * bufferHeight / (CGFloat(Device.screenHeight))
        }
        else {
            let croppedSpace = bufferHeight - (CGFloat(Device.screenHeight) * bufferWidth / CGFloat(Device.screenWidth))
            let visibleBufferHeight = bufferHeight - croppedSpace
            y = croppedSpace / 2 + point.y * visibleBufferHeight / CGFloat(Device.screenHeight)
            x = point.x * bufferWidth / CGFloat(Device.screenWidth)
        }

        let luma = int32Buffer[Int(y) * int32PerRow / heightFactor + Int(x)]
        let color = UIColor(hex: luma)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return color
    }
    
    /// Checks if media is only one photo
    /// - Returns: whether media is one photo or not
    func isMediaOnePhoto() -> Bool {
        guard playableMedia.count == 1, let onlyMedia = playableMedia.first else { return false }
        
        switch onlyMedia {
        case .image(_, _, _):
            return true
        case .video(_, _, _):
            return false
        }
    }
    
    // MARK: - Media loading

    private func loadAll(media: [MediaPlayerContent]) {
        playableMedia.removeAll()
        for item in media {
            guard let loadedMedia = MediaPlayer.loadMedia(media: item) else {
                continue
            }
            playableMedia.append(loadedMedia)
        }
        startMediaIndex = 0
        endMediaIndex = playableMedia.count - 1
    }

    private static func loadMedia(media: MediaPlayerContent) -> MediaPlayerContentLoaded? {
        switch media {
        case .image(let image, let interval):
            return loadImageMedia(image: image, interval: interval)
        case .video(let url):
            return loadVideoMedia(url: url)
        }
    }

    private static func loadVideoMedia(url: URL) -> MediaPlayerContentLoaded? {
        let playerItem = AVPlayerItem(url: url)
        let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
        playerItem.add(videoOutput)
        return .video(url, playerItem, videoOutput)
    }

    private static func loadImageMedia(image: UIImage, interval: TimeInterval? = nil) -> MediaPlayerContentLoaded? {
        guard let sampleBuffer = image.pixelBuffer()?.sampleBuffer() else {
            return nil
        }
        return .image(image, sampleBuffer, interval)
    }

    // MARK: - Playback

    private func playCurrentMedia() {
        guard let currentlyPlayingMedia = currentlyPlayingMedia else {
            return
        }
        switch currentlyPlayingMedia {
        case .image(let image, _, _):
            playerView?.currentSize = image.size
            playStill()
        case .video(_, let item, _):
            playerView?.currentSize = item.asset.tracks(withMediaType: .video).first!.naturalSize
            playVideo()
        }
    }

    private func playNextMedia() {
        if let index = playSingleFrameAtIndex {
            currentlyPlayingMediaIndex = index
        }
        else if playableMedia.count == 0 {
            currentlyPlayingMediaIndex = -1
        }
        else if playableMedia.count == 1 {
            currentlyPlayingMediaIndex = 0
        }
        else {
            switch playbackMode {
            case .loop:
                currentlyPlayingMediaIndex += 1
                if currentlyPlayingMediaIndex > endMediaIndex {
                    currentlyPlayingMediaIndex = startMediaIndex
                }
            case .reverse:
                currentlyPlayingMediaIndex -= 1
                if currentlyPlayingMediaIndex < startMediaIndex {
                    currentlyPlayingMediaIndex = endMediaIndex
                }
            case .rebound:
                if currentlyPlayingMediaIndex <= startMediaIndex {
                    currentlyPlayingMediaIndex = startMediaIndex
                    playbackDirection = 1
                }
                else if currentlyPlayingMediaIndex >= endMediaIndex {
                    currentlyPlayingMediaIndex = endMediaIndex
                    playbackDirection = -1
                }
                currentlyPlayingMediaIndex += playbackDirection
            }
        }
        playCurrentMedia()
    }

    private func playStill() {
        guard let sampleBuffer = currentlyPlayingMedia?.sampleBuffer else {
            return
        }

        // Render blurred background
//        let filter = CIFilter.gaussianBlur()
//        let image = CIImage(cvPixelBuffer: CMSampleBufferGetImageBuffer(sampleBuffer)!)
//        filter.inputImage = image
//        filter.radius = 20
//        let blurredImage = filter.outputImage!.cropped(to: image.extent)
//        playerView?.backgroundView?.image = UIImage(ciImage: blurredImage)


        let playerSize = playerView?.bounds.size ?? .zero
        let scaleSize = CGSize(width: playerSize.width * UIScreen.main.nativeScale, height: playerSize.height * UIScreen.main.nativeScale)
        renderer.processSampleBuffer(sampleBuffer, time: startTime, scaleToFillSize: scaleSize)
        renderer.switchInputDimensions = false
        renderer.mediaTransform = playerView?.mediaTransform
        
        // LOL I have to call this twice, because this was written for video, where the first frame only initializes
        // things and stuff gets rendered for the 2nd frame ¯\_(ツ)_/¯
        if playableMedia.count > 1 {
            lastStillFilterTime = Date.timeIntervalSinceReferenceDate - startTime
            renderer.processSampleBuffer(sampleBuffer, time: lastStillFilterTime, scaleToFillSize: scaleSize)
        }
        else {
            renderer.processSampleBuffer(sampleBuffer, time: lastStillFilterTime, scaleToFillSize: scaleSize)
            // If we're only playing one image, don't do anything else!
            return
        }

        if nextImageTimer?.isValid ?? false {
            nextImageTimer?.invalidate()
        }
        let displayTime = (currentlyPlayingMedia?.interval ?? delegate?.getDefaultTimeIntervalForImageSegments() ?? 1.0/6.0) / TimeInterval(rate)
        let timer = Timer.scheduledTimer(withTimeInterval: displayTime, repeats: false, block: { [weak self] _ in
            self?.playNextMedia()
        })
        RunLoop.main.add(timer, forMode: .common)
        nextImageTimer = timer
    }

    private func playVideo() {
        guard let currentlyPlayingMedia = currentlyPlayingMedia,
            let playerItem = currentlyPlayingMedia.playerItem else {
            return
        }

        if let track = currentlyPlayingMedia.asset?.tracks(withMediaType: .video).first {
            renderer.switchInputDimensions = track.orientation.isPortrait
            renderer.mediaTransform = track.glPreferredTransform
            playerView?.isPortrait = track.orientation.isPortrait
            playerView?.mediaTransform = track.glPreferredTransform
        }

        avPlayer.replaceCurrentItem(with: playerItem)

        // Rewind current AVPlayerItem to ensure playback starts from the beginning
        // (AVPlayerItems are reused when looping video, so the first time this
        // isn't necessary, but is necessary subsequent times)
        // Also, the `finished` block parameter isn't used, since if for some reason
        // seek doesn't work, we really don't have a recourse.
        playerItem.seek(to: .zero) { _ in
            self.avPlayer.play()
            self.setupDisplayLink()
        }
    }

    private func setupDisplayLink() {
        guard let currentlyPlayingMedia = currentlyPlayingMedia else {
            return
        }
        if displayLink != nil {
            displayLink?.invalidate()
            displayLink = nil
        }
        displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink?.add(to: .main, forMode: .common)
        let frameRate = currentlyPlayingMedia.asset?.tracks(withMediaType: .video).first?.nominalFrameRate ?? 10.0
        displayLink?.preferredFramesPerSecond = Int(ceil(frameRate))
    }

    @objc private func step() {
        guard let currentlyPlayingMedia = currentlyPlayingMedia else {
            return
        }
        let output = currentlyPlayingMedia.playerItemVideoOutput
        guard let itemTime = output?.itemTime(forHostTime: CACurrentMediaTime()) else {
            return
        }
        guard output?.hasNewPixelBuffer(forItemTime: itemTime) ?? false else {
            return
        }
        if let sampleBuffer = output?.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil)?.sampleBuffer() {
            let size: CGSize?
            
            if let playerView = playerView, playerView.pixelBufferView?.mediaContentMode == .scaleAspectFill {
                size = CGSize(width: playerView.frame.width * playerView.contentScaleFactor, height: playerView.frame.height * playerView.contentScaleFactor)
            } else {
                size = nil
            }
            renderer.processSampleBuffer(sampleBuffer, time: Date.timeIntervalSinceReferenceDate - startTime, scaleToFillSize: size)
        }
    }

    @objc func videoDidPlayToEndTime(notification: Notification) {
        performUIUpdate {
            self.displayLink?.invalidate()
            self.displayLink = nil
            self.playNextMedia()
        }
    }

    @objc func videoFailedToPlayToEndTime(notification: Notification) {
        print(notification.debugDescription)
    }

    private func refreshMediaAfterFilterChange() {
        // When changing the filter, we need to reload the image. Videos don't need any special treatment since the
        // next frame will use the new filter.
        guard let currentlyPlayingMedia = currentlyPlayingMedia else {
            return
        }
        switch currentlyPlayingMedia {
        case .image(_, _, _):
            lastStillFilterTime = Date.timeIntervalSinceReferenceDate - startTime
            playCurrentMedia()
        default:
            break
        }
    }
}

extension MediaPlayer: RendererDelegate {

    func rendererReadyForDisplay(image: CIImage) {
        self.playerView?.pixelBufferView?.displayImage(image)
        if !firstFrameSent {
            firstFrameSent = true
            delegate?.didDisplayFirstFrame(UIImage(ciImage: image))
        }
    }

    func rendererReadyForDisplay(pixelBuffer: CVPixelBuffer) {
        self.currentPixelBuffer = pixelBuffer
        self.playerView?.pixelBufferView?.displayPixelBuffer(pixelBuffer)
        if !firstFrameSent {
            firstFrameSent = true
            if let image = UIImage(pixelBuffer: pixelBuffer) {
                delegate?.didDisplayFirstFrame(image)
            }
        }
    }

    func rendererFilteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {
        // Empty since this method is for storage rather tha rendering
    }

    func rendererRanOutOfBuffers() {
        self.playerView?.pixelBufferView?.flushPixelBufferCache()
    }
}
