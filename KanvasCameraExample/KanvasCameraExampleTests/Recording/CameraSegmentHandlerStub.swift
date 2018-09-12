//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
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

    func addNewVideoSegment(url: URL) {
        guard let videoURL = videoURL else { return }
        let segment = CameraSegment.video(videoURL)
        segments.append(segment)
    }

    func addNewImageSegment(image: UIImage, size: CGSize, completion: @escaping (Bool, CameraSegment?) -> Void) {
        guard let url = videoURL else { return }
        let segment = CameraSegment.image(image, url)
        segments.append(segment)
        completion(true, segment)
    }

    func deleteSegment(index: Int, removeFromDisk: Bool) {
        guard index < segments.count else {
            return
        }
        segments.remove(at: index)
    }

    func currentTotalDuration() -> TimeInterval {
        let timePerSegment: TimeInterval = 2
        return Double(segments.count) * timePerSegment
    }

    func exportVideo(completion: @escaping (URL?) -> Void) {
        completion(videoURL)
    }

    func reset(removeFromDisk: Bool) {

    }

    func mergeAssets(segments: [CameraSegment], completion: @escaping (URL?) -> Void) {
        completion(videoURL)
    }

    func videoOutputSettingsForSize(size: CGSize) -> [String: Any] {
        return [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: Int(size.width), AVVideoHeightKey: Int(size.height)]
    }


}
