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

/// Callbacks for opengl player
protocol GLPlayerDelegate: class {
    /// Called then the first pixel buffer is shown
    /// - Parameter image: the first frame shown
    func didDisplayFirstFrame(_ image: UIImage)
}

/// Types of media the player can play.
enum GLPlayerMedia {
    case image(UIImage)
    case video(URL)
}

/// View for rendering the player.
final class GLPlayerView: UIView {

    weak var pixelBufferView: GLPixelBufferView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let pixelBufferView = GLPixelBufferView(frame: frame)
        pixelBufferView.add(into: self)
        self.pixelBufferView = pixelBufferView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

/// Controls the playback of many GLPlayerMedia
final class GLPlayer {

    private struct Constants {
        static let onlyImagesFrameDuration: CMTimeValue = 120
        static let frameDuration: CMTimeValue = 300
        static let timescale: CMTimeScale = 600
    }

    private enum GLPlayerMediaInternal {
        case image(UIImage, CMSampleBuffer)
        case video(URL, AVPlayerItem, AVPlayerItemVideoOutput)

        var sampleBuffer: CMSampleBuffer? {
            switch self {
            case .image(_, let sampleBuffer):
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
    }

    weak var delegate: GLPlayerDelegate?

    /// The GLRendering instance for the player.
    let renderer: GLRendering

    /// The GLPlayerView that this controls.
    weak var playerView: GLPlayerView?

    /// The last timestamp a still photo has a filter applied. This is used to replicate the filter when exporting an image.
    var lastStillFilterTime: TimeInterval = 0
    
    private var playableMedia: [GLPlayerMediaInternal] = []
    private var currentlyPlayingMediaIndex: Int = -1
    private var currentlyPlayingMedia: GLPlayerMediaInternal? {
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
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        return player
    }()

    /// Default initializer
    /// - Parameter renderer: GLRendering instance for this player to use.
    init(renderer: GLRendering?) {
        self.renderer = renderer ?? GLRenderer()
        self.renderer.delegate = self
    }

    deinit {
        stop()
    }

    // MARK: - Public API

    /// The FilterYype for the GLPlayer to use to process frames with
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
    /// - Parameter media: the list of GLPlayerMedia to play
    func play(media: [GLPlayerMedia]) {
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
    func resume() {
        playCurrentMedia()
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
        case .image(_, _):
            return true
        case .video(_, _, _):
            return false
        }
    }
    
    // MARK: - Media loading

    private func loadAll(media: [GLPlayerMedia]) {
        playableMedia.removeAll()
        for item in media {
            guard let internalMedia = GLPlayer.loadMedia(media: item) else { continue }
            playableMedia.append(internalMedia)
        }
    }

    private static func loadMedia(media: GLPlayerMedia) -> GLPlayerMediaInternal? {
        switch media {
        case .image(let image):
            return loadImageMedia(image: image)
        case .video(let url):
            return loadVideoMedia(url: url)
        }
    }

    private static func loadVideoMedia(url: URL) -> GLPlayerMediaInternal? {
        let playerItem = AVPlayerItem(url: url)
        let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
        playerItem.add(videoOutput)
        return GLPlayerMediaInternal.video(url, playerItem, videoOutput)
    }

    private static func loadImageMedia(image: UIImage) -> GLPlayerMediaInternal? {
        guard let sampleBuffer = image.pixelBuffer()?.sampleBuffer() else {
            return nil
        }
        return GLPlayerMediaInternal.image(image, sampleBuffer)
    }

    // MARK: - Playback

    private func playCurrentMedia() {
        guard let currentlyPlayingMedia = currentlyPlayingMedia else {
            return
        }
        switch currentlyPlayingMedia {
        case .image(_, _):
            playStill()
        case .video(_, _, _):
            playVideo()
        }
    }

    private func playNextMedia() {
        if currentlyPlayingMediaIndex + 1 < playableMedia.count {
            currentlyPlayingMediaIndex += 1
        }
        else {
            currentlyPlayingMediaIndex = 0
        }
        playCurrentMedia()
    }

    private func playStill() {
        guard let sampleBuffer = currentlyPlayingMedia?.sampleBuffer else {
            return
        }

        renderer.mediaTransform = nil

        // LOL I have to call this twice, because this was written for video, where the first frame only initializes
        // things and stuff gets rendered for the 2nd frame ¯\_(ツ)_/¯
        renderer.processSampleBuffer(sampleBuffer, time: startTime)
        lastStillFilterTime = Date.timeIntervalSinceReferenceDate - startTime
        renderer.processSampleBuffer(sampleBuffer, time: lastStillFilterTime)

        // If we're only playing one image, don't do anything else!
        guard playableMedia.count > 1 else {
            return
        }

        if nextImageTimer?.isValid ?? false {
            nextImageTimer?.invalidate()
        }
        let displayTime = timeIntervalForImageSegments()
        nextImageTimer = Timer.scheduledTimer(withTimeInterval: displayTime, repeats: false, block: { [weak self] _ in
            self?.playNextMedia()
        })
    }

    private func playVideo() {
        guard let currentlyPlayingMedia = currentlyPlayingMedia,
            let playerItem = currentlyPlayingMedia.playerItem else {
            return
        }

        if let track = currentlyPlayingMedia.asset?.tracks(withMediaType: .video).first {
            renderer.switchInputDimensions = track.orientation.isPortrait
            renderer.mediaTransform = track.glPreferredTransform
        }

        avPlayer.replaceCurrentItem(with: playerItem)

        // Rewind current AVPlayerItem to ensure playback starts from the beginning
        // (AVPlayerItems are reused when looping video, so the first time this
        // isn't necessary, but is necessary subsequent times)
        playerItem.seek(to: .zero) { success in
            guard success else {
                assertionFailure("Failed to rewind video")
                return
            }
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
        displayLink?.invalidate()
        displayLink = nil
        playNextMedia()
    }

    private func timeIntervalForImageSegments() -> TimeInterval {
        for media in playableMedia {
            switch media {
            case .image(_, _):
                break
            case .video(_, _, _):
                return CMTimeGetSeconds(CMTimeMake(value: Constants.frameDuration, timescale: Constants.timescale))
            }
        }
        return CMTimeGetSeconds(CMTimeMake(value: Constants.onlyImagesFrameDuration, timescale: Constants.timescale))
    }

    private func refreshMediaAfterFilterChange() {
        // When changing the filter, we need to reload the image. Videos don't need any special treatment since the
        // next frame will use the new filter.
        guard let currentlyPlayingMedia = currentlyPlayingMedia else {
            return
        }
        switch currentlyPlayingMedia {
        case .image(_, _):
            playCurrentMedia()
        default:
            break
        }
    }
}

extension GLPlayer: GLRendererDelegate {

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
