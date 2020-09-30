//
//  CameraSegmentHandlerStub.swift
//  EditorTestTests
//
//  Created by Daniela Riesgo on 29/08/2018.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import Foundation
import UIKit

final class CameraSegmentHandlerStub: SegmentsHandlerType {

    var segments: [CameraSegment] = []

    let videoURL = Bundle(for: CameraSegmentHandlerStub.self).url(forResource: "sample", withExtension: "mp4")
    let imageURL = Bundle(for: CameraSegmentHandlerStub.self).path(forResource: "sample", ofType: "png")

    func addSegment(_ segment: CameraSegment) {
        segments.append(segment)
    }

    func addNewVideoSegment(url: URL, mediaInfo: MediaInfo) {
        guard let videoURL = videoURL else { return }
        let segment = CameraSegment.video(videoURL, mediaInfo)
        segments.append(segment)
    }

    func addNewImageSegment(image: UIImage, size: CGSize, mediaInfo: MediaInfo, completion: @escaping (Bool, CameraSegment?) -> Void) {
        guard let url = videoURL else { return }
        let segment = CameraSegment.image(image, url, nil, mediaInfo)
        segments.append(segment)
        completion(true, segment)
    }

    func deleteSegment(at index: Int, removeFromDisk: Bool) {
        guard index < segments.count else {
            return
        }
        segments.remove(at: index)
    }

    func deleteAllSegments(removeFromDisk: Bool) {
        while segments.count > 0 {
            deleteSegment(at: 0, removeFromDisk: removeFromDisk)
        }
    }

    func moveSegment(from originIndex: Int, to destinationIndex: Int) {
        segments.move(from: originIndex, to: destinationIndex)
    }
    
    func currentTotalDuration() -> TimeInterval {
        let timePerSegment: TimeInterval = 2
        return Double(segments.count) * timePerSegment
    }

    func exportVideo(completion: @escaping (URL?, MediaInfo?) -> Void) {
        completion(videoURL, MediaInfo(source: .kanvas_camera))
    }

    func reset(removeFromDisk: Bool) {

    }

    func mergeAssets(segments: [CameraSegment], completion: @escaping (URL?, MediaInfo?) -> Void) {
        completion(videoURL, MediaInfo(source: .kanvas_camera))
    }

    func videoOutputSettingsForSize(size: CGSize) -> [String: Any] {
        return [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: Int(size.width), AVVideoHeightKey: Int(size.height)]
    }

    func ensureAllImagesHaveVideo(segments: [CameraSegment], completion: @escaping ([CameraSegment]) -> ()) {
        let newSegments = segments.map { (segment) -> CameraSegment in
            switch segment {
            case let .image(image, _, interval, mt):
                return CameraSegment.image(image, URL(string: ""), interval, mt)
            case let .video(url, mt):
                return CameraSegment.video(url, mt)
            }
        }
        completion(newSegments)
    }
}
