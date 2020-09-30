//
//  PixelBufferView.swift
//  KanvasCamera
//
//  Created by Taichi Matsumoto on 6/28/20.
//

import Foundation

protocol PixelBufferView: class {
    func displayPixelBuffer(_ pixelBuffer: CVPixelBuffer)
    func flushPixelBufferCache()
    func reset()
}
