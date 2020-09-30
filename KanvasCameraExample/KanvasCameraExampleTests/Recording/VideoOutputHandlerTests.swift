//
// Created by Tony Cheng on 8/27/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import Foundation
import XCTest

final class VideoOutputHandlerTests: XCTestCase {

    func setupHandler() -> VideoOutputHandler {
        let handler = VideoOutputHandler()
        return handler
    }
    
    func setupMockHandler() -> VideoOutputHandlerMock {
        let handler = VideoOutputHandlerMock()
        return handler
    }
    
    func setupAssetWriter() -> AVAssetWriter? {
        do {
            guard let url = try? URL.videoURL() else {
                return nil
            }
            let assetWriter = try AVAssetWriter(outputURL: url, fileType: .mp4)
            return assetWriter
        }
        catch {
            return nil
        }
    }
    
    func setupPixelBufferAdaptor() -> AVAssetWriterInputPixelBufferAdaptor {
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: nil)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
        return adaptor
    }

    func testStartRecording() {
        let handler = setupHandler()
        guard let assetWriter = setupAssetWriter() else {
            XCTFail("failed to create asset writer")
            return
        }
        let pixelBufferAdaptor = setupPixelBufferAdaptor()
        handler.startRecordingVideo(assetWriter: assetWriter,
                                    pixelBufferAdaptor: pixelBufferAdaptor,
                                    audioInput: nil)
        XCTAssert(handler.recording == true, "Asset writer should have started recording")
    }

    func testFinishRecordingWithoutStarting() {
        let handler = setupMockHandler()
        handler.stopRecordingVideo { success in }
        XCTAssert(handler.finishedRecording == false, "Handler cannot call finish recording when recording has not started")
    }
    
    func testFinishRecording() {
        guard let assetWriter = setupAssetWriter() else {
            XCTFail("failed to create asset writer")
            return
        }
        let handler = setupMockHandler()
        let pixelBufferAdaptor = setupPixelBufferAdaptor()
        handler.startRecordingVideo(assetWriter: assetWriter,
                                    pixelBufferAdaptor: pixelBufferAdaptor,
                                    audioInput: nil)
        handler.stopRecordingVideo { success in }
        XCTAssert(handler.finishedRecording, "Handler did not finish recording")
    }
}

final class VideoOutputHandlerMock: VideoOutputHandlerProtocol {
    var startedRecording: Bool = false
    var finishedRecording: Bool = false
    var hadAlreadyStarted: Bool = false
    
    func startRecordingVideo(assetWriter: AVAssetWriter, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, audioInput: AVAssetWriterInput?) {
        if !startedRecording {
            startedRecording = true
        }
        else {
            hadAlreadyStarted = true
        }
    }
    
    func stopRecordingVideo(completion: @escaping (Bool) -> Void) {
        if startedRecording {
            finishedRecording = true
        }
        completion(finishedRecording)
    }
    
}
