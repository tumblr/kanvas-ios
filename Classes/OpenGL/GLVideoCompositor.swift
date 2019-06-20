//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

enum GLVideoCompositorError: Error {
    case missingTrack
    case missingSourceFrame
    case missingSampleBuffer

}

class GLVideoCompositor: NSObject, AVVideoCompositing {

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

    var shouldCancelAllRequests = false

    private var renderingQueue = DispatchQueue(label: "kanvas.videocompositor.renderingqueue")

    private var renderContextQueue = DispatchQueue(label: "kanvas.videocompositor.rendercontextqueue")

    private var renderContext: AVVideoCompositionRenderContext?

    private var internalRenderContextDidChange = false

    private var renderContextDidChange: Bool {
        get {
            return renderContextQueue.sync { internalRenderContextDidChange }
        }
        set (newRenderContextDidChange) {
            renderContextQueue.sync { internalRenderContextDidChange = newRenderContextDidChange }
        }
    }

    let renderer: GLRenderer

    var firstFrame: Bool = true

    var filterType: FilterType {
        didSet {
            renderer.changeFilter(filterType)
        }
    }

    var asyncVideoCompositionRequests: [AVAsynchronousVideoCompositionRequest] = []

    override init() {
        renderer = GLRenderer()
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
            } else {
                guard let trackID = asyncVideoCompositionRequest.sourceTrackIDs.first else {
                    asyncVideoCompositionRequest.finish(with: GLVideoCompositorError.missingTrack)
                    return
                }
                guard let sourcePixelBuffer = asyncVideoCompositionRequest.sourceFrame(byTrackID: trackID.int32Value) else {
                    asyncVideoCompositionRequest.finish(with: GLVideoCompositorError.missingSourceFrame)
                    return
                }
                //guard let dstPixels = renderContext?.newPixelBuffer() else { return }
                if self.renderContextDidChange {
                    self.renderContextDidChange = false
                }

                guard let sampleBuffer = sourcePixelBuffer.sampleBuffer() else {
                    asyncVideoCompositionRequest.finish(with: GLVideoCompositorError.missingSampleBuffer)
                    return
                }

                self.asyncVideoCompositionRequests.insert(asyncVideoCompositionRequest, at: 0)
                print("Added \(self.asyncVideoCompositionRequests.count)")

                // GAH FIRST FRAME BULLSHIT!
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
    }

    func rendererFilteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {
        renderingQueue.async {
            guard let asyncVideoCompositionRequest = self.asyncVideoCompositionRequests.popLast() else {
                return
            }
            print("Popped \(self.asyncVideoCompositionRequests.count)")
            asyncVideoCompositionRequest.finish(withComposedVideoFrame: pixelBuffer)
        }
    }

    func rendererRanOutOfBuffers() {
        print("Ugh...")
    }

}
