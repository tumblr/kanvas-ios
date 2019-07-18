//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

/// Errors that can be thrown from GLVideoCompositor
enum GLVideoCompositorError: Error {
    case missingTrack
    case missingSourceFrame
    case missingSampleBuffer
}

/// Implements AVVideoCompositing, which allows for getting a CVPixelBuffer for each video frame,
/// and providing a new CVPixelBuffer to use as the frame in the output video.
final class GLVideoCompositor: NSObject, AVVideoCompositing {

    var sourcePixelBufferAttributes: [String: Any]? {
        return [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
    }

    var requiredPixelBufferAttributesForRenderContext: [String: Any] {
        return [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
    }

    private var shouldCancelAllRequests = false
    private var internalRenderContextDidChange = false
    private var firstFrame = true

    private let renderingQueue: DispatchQueue
    private let renderContextQueue: DispatchQueue
    private var renderContext: AVVideoCompositionRenderContext?
    private var asyncVideoCompositionRequests: [AVAsynchronousVideoCompositionRequest] = []

    private var renderContextDidChange: Bool {
        get {
            return renderContextQueue.sync { internalRenderContextDidChange }
        }
        set (newRenderContextDidChange) {
            renderContextQueue.sync { internalRenderContextDidChange = newRenderContextDidChange }
        }
    }

    /// The GLRendering object that should be used to process frames
    let renderer: GLRendering

    /// The FilterType used to process each frame
    var filterType: FilterType {
        didSet {
            renderer.changeFilter(filterType)
        }
    }

    /// Convenience initializer
    override convenience init() {
        self.init(
            renderingQueue: DispatchQueue(label: "kanvas.videocompositor.renderingqueue"),
            renderContextQueue: DispatchQueue(label: "kanvas.videocompositor.rendercontextqueue"),
            renderer: GLRenderer()
        )
    }

    /// Designated initializer
    init(renderingQueue: DispatchQueue, renderContextQueue: DispatchQueue, renderer: GLRendering) {
        self.renderingQueue = renderingQueue
        self.renderContextQueue = renderContextQueue
        self.renderer = renderer
        filterType = .passthrough
        super.init()
        renderer.delegate = self
    }

    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        renderContextQueue.sync { renderContext = newRenderContext }
        renderContextDidChange = true
    }

    func startRequest(_ asyncVideoCompositionRequest: AVAsynchronousVideoCompositionRequest) {
        renderingQueue.async {
            if self.shouldCancelAllRequests {
                asyncVideoCompositionRequest.finishCancelledRequest()
            }
            else {
                guard let trackID = asyncVideoCompositionRequest.sourceTrackIDs.first else {
                    asyncVideoCompositionRequest.finish(with: GLVideoCompositorError.missingTrack)
                    return
                }
                guard let sourcePixelBuffer = asyncVideoCompositionRequest.sourceFrame(byTrackID: trackID.int32Value) else {
                    asyncVideoCompositionRequest.finish(with: GLVideoCompositorError.missingSourceFrame)
                    return
                }

                if self.renderContextDidChange {
                    self.renderContextDidChange = false
                }

                guard let sampleBuffer = sourcePixelBuffer.sampleBuffer() else {
                    asyncVideoCompositionRequest.finish(with: GLVideoCompositorError.missingSampleBuffer)
                    return
                }

                self.asyncVideoCompositionRequests.insert(asyncVideoCompositionRequest, at: 0)

                if self.firstFrame {
                    self.renderer.processSampleBuffer(sampleBuffer)
                    self.firstFrame = false
                }
                self.renderer.processSampleBuffer(sampleBuffer)
            }
        }
    }

    func cancelAllPendingVideoCompositionRequests() {
        renderingQueue.sync {
            shouldCancelAllRequests = true
        }
        renderingQueue.async {
            self.shouldCancelAllRequests = false
        }
    }

}

extension GLVideoCompositor: GLRendererDelegate {

    func rendererReadyForDisplay(pixelBuffer: CVPixelBuffer) {
        // Empty since this method is for rendering, not storage
    }

    func rendererFilteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {
        renderingQueue.async {
            guard let asyncVideoCompositionRequest = self.asyncVideoCompositionRequests.popLast() else {
                return
            }
            asyncVideoCompositionRequest.finish(withComposedVideoFrame: pixelBuffer)
        }
    }

    func rendererRanOutOfBuffers() {
        // Nothing we can do here...
    }

}
