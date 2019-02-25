//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import CoreImage
import Foundation
import UIKit

/// Callback protocol for the filters
protocol FilteredInputViewControllerDelegate {
    /// Method to return a pixel buffer
    ///
    /// - Parameter pixelBuffer: the final pixel buffer
    func filteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime)
}

/// class for controlling filters and rendering with opengl
final class FilteredInputViewController: UIViewController, GLRendererDelegate {
    private lazy var renderer: GLRenderer = {
        let renderer = GLRenderer(delegate: self)
        return renderer
    }()
    private weak var previewView: GLPixelBufferView?
    private let delegate: FilteredInputViewControllerDelegate?

    /// Filters
    private var currentFilter: FilterType = .passthrough
    
    init(delegate: FilteredInputViewControllerDelegate? = nil) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPreview()
        renderer.changeFilter(currentFilter)
    }

    override func viewDidDisappear(_ animated: Bool) {
        reset()

        super.viewDidDisappear(animated)
    }
    
    // MARK: - layout
    private func setupPreview() {
        let previewView = GLPixelBufferView(frame: .zero)
        previewView.add(into: view)
        self.previewView = previewView
    }
    
    func filterSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        renderer.processSampleBuffer(sampleBuffer)
    }
    
    // MARK: - OpenGLRendererDelegate
    func rendererReadyForDisplay(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {
        DispatchQueue.main.async {
            self.delegate?.filteredPixelBufferReady(pixelBuffer: pixelBuffer, presentationTime: presentationTime)
            self.previewView?.displayPixelBuffer(pixelBuffer)
        }
    }
    
    func rendererRanOutOfBuffers() {
        previewView?.flushPixelBufferCache()
    }
    
    // MARK: - reset
    func reset() {
        renderer.reset()
        previewView?.reset()
    }

    func cleanup() {
        reset()
        previewView?.removeFromSuperview()
    }
    
    // MARK: - filtering image
    func filterImageWithCurrentPipeline(image: UIImage?) -> UIImage? {
        if let uImage = image, let pixelBuffer = uImage.pixelBuffer() {
            if let filteredPixelBuffer = renderer.processSingleImagePixelBuffer(pixelBuffer) {
                let ciImage = CIImage(cvPixelBuffer: filteredPixelBuffer)
                return UIImage(ciImage: ciImage)
            }
        }
        NSLog("failed to filter image")
        return image
    }
}
