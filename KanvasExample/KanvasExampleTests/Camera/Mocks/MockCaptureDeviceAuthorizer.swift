//
//  MockCaptureDeviceAuthorizer.swift
//  KanvasExampleTests
//
//  Created by Declan McKenna on 21/04/2022.
//  Copyright © 2022 Tumblr. All rights reserved.
//

@testable import Kanvas
import AVFoundation

final class MockCaptureDeviceAuthorizer: CaptureDeviceAuthorizing {

    var currentCameraAccess: AVAuthorizationStatus
    var currentMicrophoneAccess: AVAuthorizationStatus
    var mediaAccessRequestsMade: [AVMediaType] = []
    let requestedCameraAccessAnswer: AVAuthorizationStatus
    let requestedMicrophoneAccessAnswer: AVAuthorizationStatus

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
        let authorizationStatus: AVAuthorizationStatus? = {
            switch mediaType {
            case .video:
                currentCameraAccess = requestedCameraAccessAnswer
                return currentCameraAccess
            case .audio:
                currentMicrophoneAccess = requestedMicrophoneAccessAnswer
                return currentCameraAccess
            default:
                return nil
            }
        }()
        completionHandler(authorizationStatus == .authorized)
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
