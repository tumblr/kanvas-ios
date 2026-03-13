//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Callback protocol for the filters
protocol FilteredInputViewControllerDelegate: AnyObject {
    /// Method to return a filtered pixel buffer
    ///
    /// - Parameter pixelBuffer: the final pixel buffer
    func filteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime)
}

/// class for controlling filters and rendering with opengl
final class FilteredInputViewController: UIViewController, RendererDelegate {
    private lazy var metalContext: MetalContext = {
        guard
            let context = MetalContext.createContext()
        else {
            fatalError("Failed to create MetalContext")
        }
        return context
    }()
    private lazy var renderer: Renderer = {
        let renderer = Renderer(settings: settings, metalContext: metalContext)
        renderer.delegate = self
        return renderer
    }()
    private weak var previewView: PixelBufferView?
    private let settings: CameraSettings

    /// Filters
    private weak var delegate: FilteredInputViewControllerDelegate?
    private(set) var currentFilter: FilterType = .passthrough

    private var frameSize: CGSize = .zero
    private let startTime = Date.timeIntervalSinceReferenceDate
    
    init(delegate: FilteredInputViewControllerDelegate? = nil, settings: CameraSettings) {
        self.delegate = delegate
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        frameSize = view.frame.size
        setupPreview()

        renderer.filterType = currentFilter
        renderer.refreshFilter()
    }
    
    // MARK: - layout
    private func setupPreview() {
        if settings.features.openGLPreview {
            let previewView = GLPixelBufferView(delegate: nil, mediaContentMode: settings.features.scaleMediaToFill ? .scaleAspectFill : .scaleAspectFit)
            previewView.add(into: view)
            self.previewView = previewView
        }
        else {
            let previewView = MetalPixelBufferView(context: metalContext, mediaContentMode: settings.features.scaleMediaToFill ? .scaleAspectFill : .scaleAspectFit)
            previewView.add(into: view)
            self.previewView = previewView
        }
    }

    override func viewDidLayoutSubviews() {
        frameSize = view.frame.size
    }

    func filterSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        renderer.processSampleBuffer(sampleBuffer, time: Date.timeIntervalSinceReferenceDate - startTime, scaleToFillSize: frameSize)
    }
    
    // MARK: - RendererDelegate
    func rendererReadyForDisplay(pixelBuffer: CVPixelBuffer) {
        self.previewView?.displayPixelBuffer(pixelBuffer)
    }

    func rendererFilteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {
        self.delegate?.filteredPixelBufferReady(pixelBuffer: pixelBuffer, presentationTime: presentationTime)
    }
    
    func rendererRanOutOfBuffers() {
        previewView?.flushPixelBufferCache()
    }
    
    // MARK: - reset
    func reset() {
        renderer.reset()
        previewView?.reset()
    }

    // MARK: - filtering image
    func filterImageWithCurrentPipeline(image: UIImage?) -> UIImage? {
        if let uImage = image, let pixelBuffer = uImage.pixelBuffer() {
            if let filteredPixelBuffer = renderer.processSingleImagePixelBuffer(pixelBuffer, time: Date.timeIntervalSinceReferenceDate - startTime, scaleToFillSize: frameSize) {
                return UIImage(pixelBuffer: filteredPixelBuffer)
            }
        }
        NSLog("failed to filter image")
        return image
    }

    // MARK: - changing filters
    func applyFilter(type: FilterType) {
        currentFilter = type
        renderer.filterType = type
        renderer.refreshFilter()
    }
}
