//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

typealias MediaFrame = (image: UIImage, interval: TimeInterval)

func MediaFrameGetFrame(_ frames: [MediaFrame], at timeInterval: TimeInterval) -> (Int, MediaFrame)? {
    var frameTime: TimeInterval = .zero
    for (index, frame) in frames.enumerated() {
        if timeInterval > frameTime {
            frameTime += frame.interval
            if timeInterval < frameTime {
                return (index, frame)
            }
        }
        else if timeInterval == frameTime {
            return (index, frame)
        }
    }
    if let lastFrame = frames.last {
        return (frames.count - 1, lastFrame)
    }
    else {
        return nil
    }
}

func MediaFrameGetStartTimestamp(_ frames: [MediaFrame], at index: Int) -> TimeInterval {
    guard index >= 0, frames.count > 0, index <= frames.count else {
        return 0
    }
    return frames[0..<index].reduce(0) { (result, frame) in
        result + frame.interval
    }
}

func MediaFrameGetEndTimestamp(_ frames: [MediaFrame], at index: Int) -> TimeInterval {
    guard index >= 0, frames.count > 0, index < frames.count else {
        return 0
    }
    return frames[0...index].reduce(0) { (result, frame) in
        result + frame.interval
    }
}

protocol GifMakerHandlerDelegate: AnyObject {
    func didConfirmGif()

    func didRevertGif()

    func getDefaultTimeIntervalForImageSegments() -> TimeInterval

    func didSettingsChange(dirty: Bool)

    func configureMediaPlayer(settings: GIFMakerSettings)

    func setMediaPlayerFrame(location: CGFloat)

    func unsetMediaPlayerFrame()
}

typealias DidSettingsChangeHandler = () -> Void

private class GifMakerSettingsViewModel {

    private let didSettingsChangeHandler: DidSettingsChangeHandler

    private let initialSettings: GIFMakerSettings

    var dirty: Bool {
        return rate != initialSettings.rate ||
            startIndex != initialSettings.startIndex ||
            endIndex != initialSettings.endIndex ||
            playbackMode != initialSettings.playbackMode
    }

    var settings: GIFMakerSettings {
        return .init(rate: rate, startIndex: startIndex, endIndex: endIndex, playbackMode: playbackMode)
    }

    var rate: Float {
        didSet {
            didSettingsChangeHandler()
        }
    }

    var startIndex: Int {
        didSet {
            didSettingsChangeHandler()
        }
    }

    var endIndex: Int {
        didSet {
            didSettingsChangeHandler()
        }
    }

    var playbackMode: PlaybackOption {
        didSet {
            didSettingsChangeHandler()
        }
    }

    init(initialSettings: GIFMakerSettings.Initial, frames: [MediaFrame], didSettingsChangeHandler: @escaping DidSettingsChangeHandler) {
        self.didSettingsChangeHandler = didSettingsChangeHandler
        self.initialSettings = initialSettings.settings(frames: frames)
        self.rate = self.initialSettings.rate
        self.startIndex = self.initialSettings.startIndex
        self.endIndex = self.initialSettings.endIndex
        self.playbackMode = self.initialSettings.playbackMode
    }
}

class GifMakerHandler {

    weak var delegate: GifMakerHandlerDelegate?

    var segments: [CameraSegment]?

    var settings: GIFMakerSettings {
        settingsViewModel?.settings ?? (initialSettings ?? GIFMakerSettings.Initial()).settings(frames: [])
    }

    var shouldExport: Bool {
        hasFrames
    }

    private var dirty: Bool {
        !mediaConversionPermanent && mediaDirty
    }

    private var initialSettings: GIFMakerSettings.Initial?

    private var mediaDirty: Bool = false

    private var mediaConversionPermanent: Bool = false

    private var hasFrames: Bool {
        return frames != nil && (frames?.count ?? 0) > 0
    }

    private var settingsViewModel: GifMakerSettingsViewModel? {
        willSet {
            if settingsViewModel != nil, newValue == nil {
                resetPlayer()
            }
        }
        didSet {
            if settingsViewModel != nil {
                didSettingsChange()
            }
        }
    }

    func didSettingsChange() {
        configurePlayer()
        let dirty = self.dirty || settingsViewModel?.dirty == true
        delegate?.didSettingsChange(dirty: dirty)
    }

    private var frames: [MediaFrame]? {
        didSet {
            guard let frames = frames else {
                segments = nil
                settingsViewModel = nil
                duration = nil
                return
            }
            segments = frames.map { frame in
                CameraSegment.image(frame.image, nil, frame.interval, .init(source: .kanvas_camera))
            }
            settingsViewModel = GifMakerSettingsViewModel(initialSettings: initialSettings ?? .init(), frames: frames, didSettingsChangeHandler: didSettingsChange)
            duration = MediaFrameGetEndTimestamp(frames, at: frames.count - 1)
        }
    }

    private(set) var duration: TimeInterval?

    var trimmedDuration: TimeInterval {
        guard let settingsViewModel = settingsViewModel else {
            return 0
        }
        let startTime = MediaFrameGetStartTimestamp(frames ?? [], at: settingsViewModel.startIndex)
        let endTime = MediaFrameGetEndTimestamp(frames ?? [], at: settingsViewModel.endIndex)
        return endTime - startTime
    }

    private var thumbnails: [TimeInterval: UIImage] = [:]

    private let analyticsProvider: KanvasAnalyticsProvider?

    init(analyticsProvider: KanvasAnalyticsProvider?) {
        self.analyticsProvider = analyticsProvider
    }

    func load(segments: [CameraSegment],
              initialSettings: GIFMakerSettings.Initial,
              permanent: Bool,
              showLoading: () -> Void,
              hideLoading: @escaping () -> Void,
              completion: @escaping (Bool) -> Void) {
        if frames != nil {
            completion(false)
        }
        else {
            let defaultInterval = delegate?.getDefaultTimeIntervalForImageSegments() ?? 1.0/6.0
            showLoading()
            loadFrames(from: segments, defaultInterval: defaultInterval) { (frames, converted) in
                self.initialSettings = initialSettings
                self.mediaDirty = converted
                self.mediaConversionPermanent = permanent
                self.frames = frames
                hideLoading()
                completion(converted)
            }
        }
    }

    func revert(completion: @escaping (_ reverted: Bool) -> Void) {
        let hadFrames = self.hasFrames
        frames = nil
        mediaConversionPermanent = false
        mediaDirty = false
        DispatchQueue.main.async {
            completion(hadFrames)
        }
    }

    func trimmedSegments(_ segments: [CameraSegment]) -> [CameraSegment] {
        guard let settingsViewModel = settingsViewModel else {
            return segments
        }
        let startIndex = settingsViewModel.startIndex
        let endIndex = settingsViewModel.endIndex
        return Array(segments[startIndex...endIndex])
    }

    func framesForPlayback(_ frames: [MediaFrame]) -> [MediaFrame] {

        guard let settingsViewModel = self.settingsViewModel else {
            return frames
        }

        let getRateAdjustedFrames = { (frames: [MediaFrame]) -> [MediaFrame] in
            let rate = settingsViewModel.rate
            let timeIntervalRate = TimeInterval(rate)
            return frames.map { frame in
                return (image: frame.image, interval: frame.interval / timeIntervalRate)
            }
        }

        let getPlaybackFrames = { (frames: [MediaFrame]) -> [MediaFrame] in
            let playbackMode = settingsViewModel.playbackMode
            switch playbackMode {
            case .loop:
                return frames
            case .rebound:
                return frames + frames.reversed().dropFirst().dropLast()
            case .reverse:
                return frames.reversed()
            }
        }

        let rateAdjustedFrames = getRateAdjustedFrames(frames)

        let playbackFrames = getPlaybackFrames(rateAdjustedFrames)

        return playbackFrames
    }

    private func loadFrames(from inputSegments: [CameraSegment], defaultInterval: TimeInterval, completion: @escaping ([MediaFrame], _ convertedToFrames: Bool) -> ()) {
        let group = DispatchGroup()
        var frames: [Int: [GIFDecodeFrame]] = [:]
        let encoder = GIFEncoderImageIO()
        let decoder = GIFDecoderFactory.create(type: .imageIO)
        var converted = false

        let segments = convertLivePhotoStillToVideo(inputSegments) ?? inputSegments

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

    private func convertLivePhotoStillToVideo(_ inputSegments: [CameraSegment]) -> [CameraSegment]? {
        guard
            inputSegments.count == 1,
            let segment = inputSegments.first,
            let _ = segment.image,
            let livePhotoVideo = segment.videoURL
        else {
            return nil
        }
        return [CameraSegment.video(livePhotoVideo, segment.mediaInfo)]
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

    func configurePlayer() {
        guard let settingsViewModel = settingsViewModel else {
            return
        }
        delegate?.configureMediaPlayer(settings: settingsViewModel.settings)
    }

    func resetPlayer() {
        let initialSettings = (self.initialSettings ?? .init()).settings(frames: frames ?? [])
        delegate?.configureMediaPlayer(settings: initialSettings)
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
    }

    func didTrim(from startingPercentage: CGFloat?, to endingPercentage: CGFloat?) {
        if let percentage = startingPercentage ?? endingPercentage {
            delegate?.setMediaPlayerFrame(location: percentage / 100.0)
        }
    }

    func didEndTrimming(from startingPercentage: CGFloat, to endingPercentage: CGFloat) {
        guard let startIndex = startIndex(from: startingPercentage / 100.0) else {
            return
        }
        settingsViewModel?.startIndex = startIndex

        guard let endIndex = endIndex(from: endingPercentage / 100.0) else {
            return
        }
        settingsViewModel?.endIndex = endIndex

        delegate?.unsetMediaPlayerFrame()

        let startTime = MediaFrameGetStartTimestamp(frames ?? [], at: startIndex)
        let endTime = MediaFrameGetEndTimestamp(frames ?? [], at: endIndex)
        analyticsProvider?.logEditorGIFChange(trimStart: startTime, trimEnd: endTime)
    }

    func getThumbnail(at timestamp: TimeInterval) -> UIImage? {
        if let thumbnail = thumbnails[timestamp] {
            return thumbnail
        }
        guard let frame = MediaFrameGetFrame(frames ?? [], at: timestamp) else {
            return nil
        }
        thumbnails[timestamp] = frame.1.image
        return frame.1.image
    }

    func getMediaDuration() -> TimeInterval? {
        return duration
    }

    func didSelectSpeed(_ speed: Float) {
        settingsViewModel?.rate = speed
        analyticsProvider?.logEditorGIFChange(speed: speed)
    }

    func didSelectPlayback(_ option: PlaybackOption) {
        settingsViewModel?.playbackMode = option
        analyticsProvider?.logEditorGIFChange(playbackMode: .init(from: option))
    }

    func didOpenTrim() {
        analyticsProvider?.logEditorGIFOpenTrim()
    }

    func didOpenSpeed() {
        analyticsProvider?.logEditorGIFOpenSpeed()
    }

    func startLocation(from index: Int) -> CGFloat? {
        guard let frames = frames else {
            return nil
        }
        let timestamp = MediaFrameGetStartTimestamp(frames, at: index)
        let maxTime = min(TrimController.maxSelectableTime, MediaFrameGetEndTimestamp(frames, at: frames.count - 1))
        return CGFloat((0...maxTime).clamp(timestamp) / maxTime)
    }

    func endLocation(from index: Int) -> CGFloat? {
        guard let frames = frames else {
            return nil
        }
        let timestamp = MediaFrameGetEndTimestamp(frames, at: index)
        let maxTime = min(TrimController.maxSelectableTime, MediaFrameGetEndTimestamp(frames, at: frames.count - 1))
        return CGFloat((0...maxTime).clamp(timestamp) / maxTime)
    }
}
