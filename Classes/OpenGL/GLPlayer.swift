//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import CoreMedia
import AVFoundation

class GLPlayerView: UIView {

    weak var pixelBufferView: GLPixelBufferView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let pixelBufferView = GLPixelBufferView(frame: .zero)
        pixelBufferView.add(into: self)
        self.pixelBufferView = pixelBufferView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

protocol GLPlayerDelegate: class {
    func glPlayerDidFinishPlaying()
}

class GLPlayer {

    let renderer: GLRenderer

    weak var playerView: GLPlayerView?

    var displayLink: CADisplayLink?

    var imageSampleBuffer: CMSampleBuffer?

    var url: URL?
    var output: AVAssetReaderTrackOutput?
    var reader: AVAssetReader?

    var queuedURL: URL?
    var queuedOutput: AVAssetReaderTrackOutput?
    var queuedReader: AVAssetReader?

    var framerate: Int = 30
    var timeRange: CMTimeRange?

    weak var delegate: GLPlayerDelegate?

    init() {
        renderer = GLRenderer()
        renderer.delegate = self
    }

    deinit {
        stop()
        renderer.reset()
    }

    func playStill(image: UIImage) {
        guard let pixelBuffer = image.pixelBuffer() else {
            return
        }

        guard let sampleBuffer = pixelBuffer.sampleBuffer() else {
            return
        }

        stop()

        // LOL I have to call this twice, because this was written for video, where the first frame only initializes
        // things and stuff gets rendered for the 2nd frame ¯\_(ツ)_/¯
        renderer.processSampleBuffer(sampleBuffer)
        renderer.processSampleBuffer(sampleBuffer)
    }

    func play(image: UIImage) {
        guard let pixelBuffer = image.pixelBuffer() else {
            return
        }

        guard let sampleBuffer = pixelBuffer.sampleBuffer() else {
            return
        }

        imageSampleBuffer = sampleBuffer
        url = nil

        play()
    }

    func play(url: URL) {
        if url == queuedURL {
            self.reader = queuedReader
            self.output = queuedOutput
            queuedReader = nil
            queuedOutput = nil
            queuedURL = nil
        }
        else {
            let (readerMaybe, outputMaybe) = GLPlayer.getReaderAndOutput(url: url)
            self.reader = readerMaybe
            self.output = outputMaybe
        }

        guard let reader = self.reader, let output = self.output else {
            return
        }

        timeRange = output.track.timeRange
        framerate = Int(output.track.nominalFrameRate)
        reader.startReading()

        self.url = url
        imageSampleBuffer = nil

        play()
    }

    func queue(url: URL) {
        guard url != queuedURL else {
            return
        }
        let (reader, output) = GLPlayer.getReaderAndOutput(url: url)
        queuedURL = url
        queuedOutput = output
        queuedReader = reader
    }

    private func play() {
        if displayLink == nil {
            let link = CADisplayLink(target: self, selector: #selector(step))
            link.add(to: .main, forMode: .common)
            self.displayLink = link
        }
        self.displayLink?.preferredFramesPerSecond = framerate
    }

    func stop() {
        url = nil
        imageSampleBuffer = nil
        reader?.cancelReading()
        displayLink?.invalidate()
        displayLink = nil
        reader = nil
        output = nil
    }

    func rewind() {
        if let timeRange = timeRange {
            output?.reset(forReadingTimeRanges: [timeRange as NSValue])
        }
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

    @objc func step() {
        guard let displayLink = displayLink else {
            return
        }
        let actualFramesPerSecond = 1 / (displayLink.targetTimestamp - displayLink.timestamp)
        print(actualFramesPerSecond)

        if let imageSampleBuffer = imageSampleBuffer {
            renderer.processSampleBuffer(imageSampleBuffer)
        }
        else if let sampleBuffer = output?.copyNextSampleBuffer() {
            renderer.processSampleBuffer(sampleBuffer)
        }
        else {
            delegate?.glPlayerDidFinishPlaying()
        }
    }
}

extension GLPlayer: GLRendererDelegate {

    func rendererReadyForDisplay(pixelBuffer: CVPixelBuffer) {
        self.playerView?.pixelBufferView?.displayPixelBuffer(pixelBuffer)
    }

    func rendererFilteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {

    }

    func rendererRanOutOfBuffers() {
        self.playerView?.pixelBufferView?.flushPixelBufferCache()
    }

}
