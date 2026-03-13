//
//  MockCaptureDeviceAuthorizer.swift
//  KanvasExampleTests
//
//  Created by Declan McKenna on 21/04/2022.
//  Copyright © 2022 Tumblr. All rights reserved.
//

@testable import Kanvas
import AVFoundation
import XCTest

final class MockCaptureDeviceAuthorizer: CaptureDeviceAuthorizing {

    private(set) var mediaAccessRequestsMade: [AVMediaType] = []
    private let requestedCameraAccessAnswer: AVAuthorizationStatus
    private let requestedMicrophoneAccessAnswer: AVAuthorizationStatus
    private var currentCameraAccess: AVAuthorizationStatus
    private var currentMicrophoneAccess: AVAuthorizationStatus

    init(initialCameraAccess: AVAuthorizationStatus,
         initialMicrophoneAccess: AVAuthorizationStatus,
         requestedCameraAccessAnswer: AVAuthorizationStatus = .notDetermined,
         requestedMicrophoneAccessAnswer: AVAuthorizationStatus = .notDetermined) {
        
        self.currentCameraAccess = initialCameraAccess
        self.currentMicrophoneAccess = initialMicrophoneAccess
        self.requestedCameraAccessAnswer = requestedCameraAccessAnswer
        self.requestedMicrophoneAccessAnswer = requestedMicrophoneAccessAnswer
    }

    func requestAccess(for mediaType: AVMediaType, completionHandler: @escaping (Bool) -> ()) {
        mediaAccessRequestsMade.append(mediaType)
        switch mediaType {
        case .video:
            currentCameraAccess = requestedCameraAccessAnswer
            completionHandler(requestedCameraAccessAnswer.isAuthorized)
        case .audio:
            currentMicrophoneAccess = requestedMicrophoneAccessAnswer
            completionHandler(requestedMicrophoneAccessAnswer.isAuthorized)
        default:
            XCTFail("\(mediaType) is not currently supported by this mock, please implement it!")
        }
    }

    func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
        switch mediaType {
        case .video:
            return currentCameraAccess
        case .audio:
            return currentMicrophoneAccess
        default:
            return .denied
        }
    }
}

private extension AVAuthorizationStatus {
    var isAuthorized: Bool { self == .authorized }
}
