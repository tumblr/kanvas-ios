//
//  Rendering.swift
//  KanvasCamera
//
//  Created by Jimmy Schementi on 11/10/19.
//

import Foundation
import CoreMedia
import GLKit

protocol Rendering: class {
    var delegate: RendererDelegate? { get set }
    var filterType: FilterType { get set }
    var imageOverlays: [CGImage] { get set }
    var mediaTransform: GLKMatrix4? { get set }
    var switchInputDimensions: Bool { get set }
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval)
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval, scaleToFillSize: CGSize?)
    func processSingleImagePixelBuffer(_ pixelBuffer: CVPixelBuffer, time: TimeInterval, scaleToFillSize: CGSize?) -> CVPixelBuffer?
    func refreshFilter()
    func reset()
}
