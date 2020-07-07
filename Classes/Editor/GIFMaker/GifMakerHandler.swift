//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

typealias MediaFrame = (image: UIImage, interval: TimeInterval)

protocol GifMakerHandlerDelegate: class {
    func didConfirmGif()

    func didRevertGif()

    func getDefaultTimeIntervalForImageSegments() -> TimeInterval

    func didSettingsChange(dirty: Bool)
}

typealias DidSettingsChangeHandler = () -> Void

class GifMakerSettingsViewModel {

    private let player: MediaPlayer

    private let didSettingsChangeHandler: DidSettingsChangeHandler

    private var baseSettings: GIFMakerSettings?

    var dirty: Bool {
        return rate != baseSettings?.rate ||
            playbackMode != baseSettings?.playbackMode
    }

    var settings: GIFMakerSettings? {
        guard let rate = rate, let startIndex = startIndex, let endIndex = endIndex, let playbackMode = playbackMode else {
            return nil
        }
        return .init(rate: rate, startIndex: startIndex, endIndex: endIndex, playbackMode: playbackMode)
    }

    var rate: Float? {
        didSet {
            player.rate = rate ?? GIFMakerSettings.rate
            didSettingsChangeHandler()
        }
    }

    var startIndex: Int? {
        didSet {
            guard let startIndex = startIndex else { return }
            player.startMediaIndex = startIndex
        }
    }

    var endIndex: Int? {
        didSet {
            guard let endIndex = endIndex else { return }
            player.endMediaIndex = endIndex
        }
    }

    var playbackMode: PlaybackOption? {
        didSet {
            guard let playbackMode = playbackMode else { return }
            player.playbackMode = .init(from: playbackMode)
            didSettingsChangeHandler()
        }
    }

    init(player: MediaPlayer, didSettingsChangeHandler: @escaping DidSettingsChangeHandler) {
        self.player = player
        self.didSettingsChangeHandler = didSettingsChangeHandler
    }

    func update(settings: GIFMakerSettings) {
        rate = settings.rate
        startIndex = settings.startIndex
        endIndex = settings.endIndex
        playbackMode = settings.playbackMode
        baseSettings = settings
    }

    func reset() {
        rate = GIFMakerSettings.rate
        startIndex = nil
        endIndex = nil
        playbackMode = GIFMakerSettings.playbackMode
        baseSettings = nil
    }
}

class GifMakerHandler {

    weak var delegate: GifMakerHandlerDelegate?

    var segments: [CameraSegment]?

    var hasFrames: Bool {
        return frames != nil && (frames?.count ?? 0) > 0
    }

    var settings: GIFMakerSettings? {
        settingsViewModel.settings
    }

    var defaultSettings: GIFMakerSettings?

    var convertedMediaToGIF: Bool = false

    private let player: MediaPlayer

    private lazy var settingsViewModel: GifMakerSettingsViewModel = {
        .init(player: player, didSettingsChangeHandler: didSettingsChange)
    }()

    func didSettingsChange() {
        let dirty = convertedMediaToGIF || settingsViewModel.dirty
        delegate?.didSettingsChange(dirty: dirty)
    }

    private var frames: [MediaFrame]? {
        didSet {
            guard let frames = frames else {
                segments = nil
                settingsViewModel.reset()
                duration = nil
                defaultSettings = nil
                return
            }
            segments = frames.map { frame in
                CameraSegment.image(frame.image, nil, frame.interval, .init(source: .kanvas_camera))
            }
            let defaultSettings = GIFMakerSettings.default(startIndex: 0, endIndex: frames.count - 1)
            self.defaultSettings = defaultSettings
            settingsViewModel.update(settings: defaultSettings)
            duration = frames.reduce(0) { (duration, frame) in
                return duration + frame.interval
            }
        }
    }

    private(set) var duration: TimeInterval?

    var trimmedDuration: TimeInterval {
        guard let startIndex = settingsViewModel.startIndex, let endIndex = settingsViewModel.endIndex else {
            return 0
        }
        let startTime = getTimestamp(at: startIndex)
        let endTime = getTimestamp(at: endIndex)
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

            loadFrames(from: segments, defaultInterval: defaultInterval) { (frames, converted) in
                self.frames = frames
                self.convertedMediaToGIF = converted
                hideLoading()
                completion(converted)
                self.didSettingsChange()
            }
        }
    }

    func revert(completion: @escaping (_ reverted: Bool) -> Void) {
        let hadFrames = self.hasFrames
        frames = nil
        DispatchQueue.main.async {
            completion(hadFrames)
        }
    }

    func trimmedSegments(_ segments: [CameraSegment]) -> [CameraSegment] {
        guard let startIndex = settingsViewModel.startIndex, let endIndex = settingsViewModel.endIndex else {
            return segments
        }
        return Array(segments[startIndex...endIndex])
    }

    func framesForPlayback(_ frames: [MediaFrame]) -> [MediaFrame] {

        let getRateAdjustedFrames = { (frames: [MediaFrame]) -> [MediaFrame] in
            guard let rate = self.settingsViewModel.rate else {
                return frames
            }
            let timeIntervalRate = TimeInterval(rate)
            return frames.map { frame in
                return (image: frame.image, interval: frame.interval / timeIntervalRate)
            }
        }

        let getPlaybackFrames = { (frames: [MediaFrame]) -> [MediaFrame] in
            guard let playbackMode = self.settingsViewModel.playbackMode else {
                return frames
            }
            switch playbackMode {
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

    private func loadFrames(from segments: [CameraSegment], defaultInterval: TimeInterval, completion: @escaping ([MediaFrame], _ convertedToFrames: Bool) -> ()) {
        let group = DispatchGroup()
        var frames: [Int: [GIFDecodeFrame]] = [:]
        let encoder = GIFEncoderImageIO()
        let decoder = GIFDecoderFactory.create(type: .imageIO)
        var converted = false

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
                        converted = true
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
            completion(mediaFrames, converted)
        }
    }

    func startIndex(from location: CGFloat) -> Int? {
        guard let segments = segments else {
            return nil
        }
        return max(Int(CGFloat(segments.count) * location), 0)
    }

    func endIndex(from location: CGFloat) -> Int? {
        guard let segments = segments else {
            return nil
        }
        return min(Int(CGFloat(segments.count) * location), segments.count - 1)
    }
}

extension GifMakerHandler: GifMakerControllerDelegate {

    func didConfirmGif() {
        delegate?.didConfirmGif()
    }

    func didRevertGif() {
        delegate?.didRevertGif()
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
        guard let startIndex = startIndex(from: startingPercentage / 100.0) else {
            return
        }
        settingsViewModel.startIndex = startIndex

        guard let endIndex = endIndex(from: endingPercentage / 100.0) else {
            return
        }
        settingsViewModel.endIndex = endIndex

        player.cancelPlayingSingleFrame()
        previousTrim = nil

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
        settingsViewModel.rate = speed
        analyticsProvider?.logEditorGIFChange(speed: speed)
    }

    func didSelectPlayback(_ option: PlaybackOption) {
        settingsViewModel.playbackMode = option
        analyticsProvider?.logEditorGIFChange(playbackMode: .init(from: option))
    }

    func didOpenTrim() {
        analyticsProvider?.logEditorGIFOpenTrim()
    }

    func didOpenSpeed() {
        analyticsProvider?.logEditorGIFOpenSpeed()
    }
}
