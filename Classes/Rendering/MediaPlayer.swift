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
final class MediaPlayerView: UIView, GLPixelBufferViewDelegate {

    weak var pixelBufferView: PixelBufferView?
    
    var mediaTransform: GLKMatrix4? {
        didSet {
            pixelBufferView?.mediaTransform = mediaTransform
        }
    }
    
    var isPortrait: Bool = true {
        didSet {
            pixelBufferView?.isPortrait = isPortrait
        }
    }

    weak var delegate: MediaPlayerViewDelegate?

    init(metalContext: MetalContext?) {
        super.init(frame: .zero)

        let pixelBufferView: PixelBufferView & UIView
        if let metalContext = metalContext {
            pixelBufferView = MetalPixelBufferView(context: metalContext)
        }
        else {
            pixelBufferView = GLPixelBufferView(delegate: self, mediaContentMode: .scaleAspectFit)
        }

        pixelBufferView.add(into: self)
        self.pixelBufferView = pixelBufferView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - GLPixelBufferViewDelegate

    func didRenderRectChange(rect: CGRect) {
        delegate?.didRenderRectChange(rect: rect)
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
    weak var playerView: MediaPlayerView?

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

    func getFrame(at index: Int) -> UIImage? {
        guard index >= 0 && index < playableMedia.count else {
            return nil
        }
        switch playableMedia[index] {
        case .image(let image, _, _):
            return image
        case .video(_, _, _):
            return nil
        }
    }

    /// Default initializer
    /// - Parameter renderer: Rendering instance for this player to use.
    init(renderer: Rendering?) {
        self.renderer = renderer ?? Renderer()
        self.renderer.delegate = self
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
        case .image(_, _, _):
            playStill()
        case .video(_, _, _):
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

        renderer.switchInputDimensions = false
        renderer.mediaTransform = nil
        
        renderer.processSampleBuffer(sampleBuffer, time: startTime)
        
        // LOL I have to call this twice, because this was written for video, where the first frame only initializes
        // things and stuff gets rendered for the 2nd frame ¯\_(ツ)_/¯
        if playableMedia.count > 1 {
            lastStillFilterTime = Date.timeIntervalSinceReferenceDate - startTime
            renderer.processSampleBuffer(sampleBuffer, time: lastStillFilterTime)
        }
        else {
            renderer.processSampleBuffer(sampleBuffer, time: lastStillFilterTime)
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
            renderer.processSampleBuffer(sampleBuffer, time: Date.timeIntervalSinceReferenceDate - startTime)
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
