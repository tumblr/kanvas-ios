//
//  FilterProtocol.swift
//  KanvasCamera
//
//  Created by Tony Cheng on 12/10/18.
//

import AVFoundation
import Foundation
import GLKit

/// Protocol for filters
protocol FilterProtocol: class {

    /// Uses the sampleBuffer's dimensions to initialize framebuffers and pixel buffers.
    func setupFormatDescription(from sampleBuffer: CMSampleBuffer, transform: GLKMatrix4?, outputDimensions: CGSize)
    func setupFormatDescription(inputDimensions: CGSize, transform: GLKMatrix4?, outputDimensions: CGSize)

    /// Uses the provided pixelBuffer to render the filter to a new pixel buffer, and returns the new pixel buffer.
    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer?, time: TimeInterval) -> CVPixelBuffer?

    /// Cleans up all resources allocated by the filter.
    func cleanup()

    /// Output format set by setupFormatDescription
    var outputFormatDescription: CMFormatDescription? { get }

    var transform: GLKMatrix4? { get }

    var switchInputDimensions: Bool { get set }

}
