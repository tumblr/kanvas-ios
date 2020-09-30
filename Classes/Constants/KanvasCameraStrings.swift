//
//  KanvasCameraStrings.swift
//  KanvasEditor
//
//  Created by Daniela Riesgo on 14/08/2018.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//

import Foundation

// the values for common string throughout the module
struct KanvasCameraStrings {
    // MARK: - Camera Modes

    // photoModeName: used in the camera mode button
    static let photoModeName: String = NSLocalizedString("Photo", comment: "Photo camera mode")

    // loopModeName: used in the camera mode button
    static let loopModeName: String = NSLocalizedString("Loop", comment: "Gif camera mode")

    // stopMotionModeName: used in the camera mode button
    static let stopMotionModeName: String = NSLocalizedString("Capture", comment: "Stop motion camera mode")
    
    // normalModeName: used in the camera mode button
    static let normalModeName: String = NSLocalizedString("Normal", comment: "Normal camera mode")
    
    // stitchModeName: used in the camera mode button
    static let stitchModeName: String = NSLocalizedString("Stitch", comment: "Stitch camera mode")
    
    // gifModeName: used in the camera mode button
    static let gifModeName: String = NSLocalizedString("GIF", comment: "GIF camera mode")
    
    static func name(for mode: CameraMode) -> String {
        switch mode {
        case .photo: return photoModeName
        case .loop: return loopModeName
        case .stopMotion: return stopMotionModeName
        case .normal: return normalModeName
        case .stitch: return stitchModeName
        case .gif: return gifModeName
        }
    }

    static func bundlePath(for aClass: AnyClass) -> String? {
        return Bundle(for: aClass).path(forResource: "KanvasCamera", ofType: "bundle")
    }
}
