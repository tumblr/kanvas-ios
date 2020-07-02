//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

typealias MediaFrame = (image: UIImage, interval: TimeInterval)

protocol GifMakerHandlerDelegate: class {
    func didConfirmGif()

    func getDefaultTimeIntervalForImageSegments() -> TimeInterval
}

class GifMakerHandler {

    weak var delegate: GifMakerHandlerDelegate?

    var segments: [CameraSegment]?

    var hasFrames: Bool {
        return frames != nil && (frames?.count ?? 0) > 0
    }

    private let player: MediaPlayer

    private(set) var settings: GIFMakerSettings?

    private var frames: [MediaFrame]? {
        didSet {
            guard let frames = frames else {
                segments = nil
                settings = nil
                duration = nil
                return
            }
            segments = frames.map { frame in
                CameraSegment.image(frame.image, nil, frame.interval, .init(source: .kanvas_camera))
            }
            settings = GIFMakerSettings(rate: 1, startIndex: 0, endIndex: frames.count - 1, playbackMode: .loop)
            duration = frames.reduce(0) { (duration, frame) in
                return duration + frame.interval
            }
        }
    }

    private(set) var duration: TimeInterval?

    var trimmedDuration: TimeInterval {
        guard let settings = settings else {
            return 0
        }
        let startTime = getTimestamp(at: settings.startIndex)
        let endTime = getTimestamp(at: settings.endIndex)
        return endTime - startTime
    }

    private var thumbnails: [TimeInterval: UIImage] = [:]

    private var previousTrim: ClosedRange<CGFloat>?

    private let analyticsProvider: KanvasCameraAnalyticsProvider?

    init(player: MediaPlayer, analyticsProvider: KanvasCameraAnalyticsProvider?) {
        self.player = player
        self.analyticsProvider = analyticsProvider
    }

    func load(segments: [CameraSegment], showLoading: () -> Void, hideLoading: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        if frames != nil {
            completion(false)
        }
        else {
            let defaultInterval = delegate?.getDefaultTimeIntervalForImageSegments() ?? 1.0/6.0
            showLoading()
            loadFrames(from: segments, defaultInterval: defaultInterval) { frames in
                self.frames = frames
                hideLoading()
                completion(true)
            }
        }
    }

    func trimmedSegments(_ segments: [CameraSegment]) -> [CameraSegment] {
        guard let settings = settings else {
            return segments
        }
        return Array(segments[settings.startIndex...settings.endIndex])
    }

    func framesForPlayback(_ frames: [MediaFrame]) -> [MediaFrame] {
        guard let settings = settings else {
            return frames
        }

        let rate = TimeInterval(settings.rate)

        let getRateAdjustedFrames = { (frames: [MediaFrame]) -> [MediaFrame] in
            return frames.map { frame in
                return (image: frame.image, interval: frame.interval / rate)
            }
        }

        let getPlaybackFrames = { (frames: [MediaFrame]) -> [MediaFrame] in
            switch settings.playbackMode {
            case .loop:
                return frames
            case .rebound:
                return frames + frames.reversed()[1...frames.count - 2]
            case .reverse:
                return frames.reversed()
            }
        }

        let rateAdjustedFrames = getRateAdjustedFrames(frames)

        let playbackFrames = getPlaybackFrames(rateAdjustedFrames)

        return playbackFrames
    }

    private func loadFrames(from segments: [CameraSegment], defaultInterval: TimeInterval, completion: @escaping ([MediaFrame]) -> ()) {
        let group = DispatchGroup()
        var frames: [Int: [GIFDecodeFrame]] = [:]
        let encoder = GIFEncoderImageIO()
        let decoder = GIFDecoderFactory.create(type: .imageIO)
        for (i, segment) in segments.enumerated() {
            if let cgImage = segment.image?.cgImage {
                frames[i] = [(image: cgImage, interval: segment.timeInterval ?? defaultInterval)]
            }
            else if let videoURL = segment.videoURL {
                group.enter()
                encoder.encode(video: videoURL, loopCount: 0, framesPerSecond: 10) { gifURL in
                    guard let gifURL = gifURL else {
                        group.leave()
                        return
                    }
                    decoder.decode(image: gifURL) { gifFrames in
                        frames[i] = gifFrames
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: .main) {
            let orderedFrames = frames.keys.sorted().reduce([]) { (partialOrderedFrames, index) in
                return partialOrderedFrames + (frames[index] ?? [])
            }
            let mediaFrames = orderedFrames.map { (image: UIImage(cgImage: $0.image), interval: $0.interval) }
            completion(mediaFrames)
        }
    }
}

extension GifMakerHandler: GifMakerControllerDelegate {

    func didConfirmGif() {
        delegate?.didConfirmGif()
    }

    func didStartTrimming() {
        previousTrim = 0.0...100.0
    }

    func didTrim(from startingPercentage: CGFloat, to endingPercentage: CGFloat) {
        guard let previousTrim = previousTrim else {
            return
        }
        if previousTrim.lowerBound != startingPercentage {
            player.playSingleFrame(at: startingPercentage / 100.0)
        }
        else if previousTrim.upperBound != endingPercentage {
            player.playSingleFrame(at: endingPercentage / 100.0)
        }
        self.previousTrim = startingPercentage...endingPercentage
    }

    func didEndTrimming(from startingPercentage: CGFloat, to endingPercentage: CGFloat) {
        guard let segments = segments else {
            return
        }
        previousTrim = nil
        let startLocation = startingPercentage / 100.0
        var startIndex = Int(CGFloat(segments.count) * startLocation)
        if startIndex < 0 {
            startIndex = 0
        }
        player.startMediaIndex = startIndex

        let endLocation = endingPercentage / 100.0
        var endIndex = Int(CGFloat(segments.count) * endLocation)
        if endIndex > segments.count - 1 {
            endIndex = segments.count - 1
        }
        player.endMediaIndex = endIndex

        player.cancelPlayingSingleFrame()

        settings?.startIndex = startIndex
        settings?.endIndex = endIndex

        let startTime = getTimestamp(at: startIndex)
        let endTime = getTimestamp(at: endIndex)
        analyticsProvider?.logEditorGIFChange(trimStart: startTime, trimEnd: endTime)
    }

    private func getTimestamp(at index: Int) -> TimeInterval {
        var frameTime: TimeInterval = .zero
        for (i, frame) in (frames ?? []).enumerated() {
            if i == index {
                break
            }
            frameTime += frame.interval
        }
        return frameTime
    }

    func getThumbnail(at timestamp: TimeInterval) -> UIImage? {
        if let thumbnail = thumbnails[timestamp] {
            return thumbnail
        }
        var frameTime: TimeInterval = .zero
        for frame in frames ?? [] {
            if timestamp > frameTime {
                frameTime += frame.interval
                if timestamp < frameTime {
                    thumbnails[timestamp] = frame.image
                    return frame.image
                }
            }
            else if timestamp == frameTime {
                thumbnails[timestamp] = frame.image
                return frame.image
            }
        }
        return frames?.last?.image
    }

    func getMediaDuration() -> TimeInterval? {
        return duration
    }

    func didSelectSpeed(_ speed: Float) {
        player.rate = speed
        settings?.rate = speed
        analyticsProvider?.logEditorGIFChange(speed: speed)
    }

    func didSelectPlayback(_ option: PlaybackOption) {
        player.playbackMode = .init(from: option)
        settings?.playbackMode = option
        analyticsProvider?.logEditorGIFChange(playbackMode: .init(from: option))
    }

    func didOpenTrim() {
        analyticsProvider?.logEditorGIFOpenTrim()
    }

    func didOpenSpeed() {
        analyticsProvider?.logEditorGIFOpenSpeed()
    }
}
