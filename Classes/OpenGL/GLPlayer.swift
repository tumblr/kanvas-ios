//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import CoreMedia
import AVFoundation
import VideoToolbox

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
        case video(URL, AVAssetReader, AVAssetReaderTrackOutput)

        func sampleBuffer() -> CMSampleBuffer? {
            switch self {
            case .image(_, let sampleBuffer):
                return sampleBuffer
            default:
                return nil
            }
        }

        func assetReaderOutput() -> (AVAssetReader?, AVAssetReaderTrackOutput?) {
            switch self {
            case .video(_, let reader, let output):
                return (reader, output)
            default:
                return (nil, nil)
            }
        }
    }

    private var playableMedia: [GLPlayerMediaInternal] = []
    private var currentlyPlayingMediaIndex: Int = -1
    private var currentlyPlayingMedia: GLPlayerMediaInternal? {
        guard currentlyPlayingMediaIndex >= 0 && currentlyPlayingMediaIndex < playableMedia.count else {
            return nil
        }
        return playableMedia[currentlyPlayingMediaIndex]
    }
    private var timer: Timer?
    private var displayLink: CADisplayLink?
    private var currentPixelBuffer: CVPixelBuffer?

    /// The GLRendering instance for the player.
    let renderer: GLRendering

    /// The GLPlayerView that this controls.
    weak var playerView: GLPlayerView?

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
            renderer.changeFilter(newValue ?? .off)
            refreshMediaAfterFilterChange()
        }
    }

    /// Plays a list of media repeatidly.
    /// - Parameter media: the list of GLPlayerMedia to play
    func play(media: [GLPlayerMedia]) {
        guard media.count > 0 else {
            return
        }
        currentlyPlayingMediaIndex = 0
        loadAll(media: media)
        playCurrentMedia()
    }

    /// Stops the playback of media
    func stop() {
        currentlyPlayingMediaIndex = -1
        displayLink?.invalidate()
        displayLink = nil
        timer?.invalidate()
        timer = nil
        for item in playableMedia {
            switch item {
            case .image(_, _):
                break
            case .video(_, let reader, _):
                reader.cancelReading()
            }
        }
        playableMedia.removeAll()
        renderer.reset()
    }

    /// Pauses the playback of media.
    func pause() {
        displayLink?.invalidate()
        displayLink = nil
        timer?.invalidate()
        timer = nil
        renderer.reset()
    }

    /// Resumes the playback of media.
    /// Can be used to resume playback after a call to `pause`.
    /// Unspecified behavior if used after `stop` ¯\_(ツ)_/¯
    func resume() {
        // A AVAssetReader and AVAssetReaderTrackOutput combo needs to be re-created when the app comes back
        // from the background. Without this, the AVAssetReaderTrackOutput thinks it is ready for reading, but
        // copyNextSampleBuffer returns nil, thought reset(forReadingTimeRanges:) doesn't think it should be.
        reloadAllMedia()

        renderer.reset()
        playCurrentMedia()
    }
    
    /// Obtains the first frame from playable media
    ///
    /// - Returns: first frame
    func getFirstFrame() -> UIImage {
        guard let pixelBuffer = currentPixelBuffer else { return UIImage() }
        var cgImageMaybe: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImageMaybe)
        guard let cgImage = cgImageMaybe else { return UIImage() }
        return UIImage(cgImage: cgImage)
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

    private func reloadAllMedia() {
        let newPlayableMedia = playableMedia.compactMap { GLPlayer.reloadMedia(media: $0) }
        playableMedia.removeAll()
        playableMedia.append(contentsOf: newPlayableMedia)
    }

    private static func reloadMedia(media: GLPlayerMediaInternal) -> GLPlayerMediaInternal? {
        switch media {
        case .image(let image, _):
            return loadImageMedia(image: image)
        case .video(let url, let oldReader, _):
            oldReader.cancelReading()
            return loadVideoMedia(url: url)
        }
    }

    private static func loadVideoMedia(url: URL) -> GLPlayerMediaInternal? {
        let (readerMaybe, outputMaybe) = GLPlayer.getReaderAndOutput(url: url)
        guard let reader = readerMaybe, let output = outputMaybe else {
            return nil
        }
        // Yes, we start reading immediately! This is a slight optimization, as this results in all the video media
        // being ready for reading, meaning less delay in-between loading videos.
        reader.startReading()
        return GLPlayerMediaInternal.video(url, reader, output)
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
        else if currentlyPlayingMediaIndex < 0 {
            currentlyPlayingMediaIndex = 0
        }
        else {
            currentlyPlayingMediaIndex = 0
        }
        playCurrentMedia()
    }

    private func playStill() {
        guard let sampleBuffer = currentlyPlayingMedia?.sampleBuffer() else {
            return
        }

        // LOL I have to call this twice, because this was written for video, where the first frame only initializes
        // things and stuff gets rendered for the 2nd frame ¯\_(ツ)_/¯
        renderer.processSampleBuffer(sampleBuffer)
        renderer.processSampleBuffer(sampleBuffer)

        // If we're only playing one image, don't do anything else!
        guard playableMedia.count > 1 else {
            return
        }

        if timer?.isValid ?? false {
            timer?.invalidate()
        }
        let displayTime = timeIntervalForImageSegments()
        timer = Timer.scheduledTimer(withTimeInterval: displayTime, repeats: false, block: { [weak self] _ in
            self?.playNextMedia()
        })
    }

    private func playVideo() {
        guard let currentlyPlayingMedia = currentlyPlayingMedia else {
            return
        }
        let (readerMaybe, outputMaybe) = currentlyPlayingMedia.assetReaderOutput()
        guard let _ = readerMaybe, let output = outputMaybe else {
            return
        }

        if displayLink == nil {
            let link = CADisplayLink(target: self, selector: #selector(step))
            self.displayLink = link
        }
        self.displayLink?.add(to: .main, forMode: .common)
        let frameRate = output.track.nominalFrameRate
        self.displayLink?.preferredFramesPerSecond = Int(ceil(frameRate))
    }

    private static func getReaderAndOutput(url: URL) -> (AVAssetReader?, AVAssetReaderTrackOutput?) {
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else {
            return (nil, nil)
        }
        let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
        trackOutput.supportsRandomAccess = true
        guard let reader = try? AVAssetReader(asset: asset) else {
            return (nil, nil)
        }
        reader.add(trackOutput)

        return (reader, trackOutput)
    }

    @objc private func step() {
        guard let displayLink = displayLink else {
            return
        }
        guard let currentlyPlayingMedia = currentlyPlayingMedia else {
            return
        }
        let (_, output) = currentlyPlayingMedia.assetReaderOutput()
        if let sampleBuffer = output?.copyNextSampleBuffer() {
            renderer.processSampleBuffer(sampleBuffer)
        }
        else {
            displayLink.remove(from: .main, forMode: .common)
            if let timeRange = output?.track.timeRange {
                output?.reset(forReadingTimeRanges: [timeRange as NSValue])
            }
            playNextMedia()
        }
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
    
    private func getFirstFrame(from url: URL) -> UIImage {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTimeMake(value: 0, timescale: 2)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        }
        catch {
            return UIImage()
        }
    }
}

extension GLPlayer: GLRendererDelegate {

    func rendererReadyForDisplay(pixelBuffer: CVPixelBuffer) {
        self.playerView?.pixelBufferView?.displayPixelBuffer(pixelBuffer)
    }

    func rendererFilteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {
        self.currentPixelBuffer = pixelBuffer
    }

    func rendererRanOutOfBuffers() {
        self.playerView?.pixelBufferView?.flushPixelBufferCache()
    }

}
