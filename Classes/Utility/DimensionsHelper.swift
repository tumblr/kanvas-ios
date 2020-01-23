//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GLKit

func resizeSourceToFitInsideTarget(sourceSize: CGSize, targetSize: CGSize) -> CGSize {
    let sourceResolution = sourceSize.width / sourceSize.height
    let targetResolution = targetSize.width / targetSize.height
    if targetResolution > sourceResolution {
        return CGSize(
            width: sourceSize.width * (targetSize.height / sourceSize.height),
            height: targetSize.height
        )
    }
    else {
        return CGSize(
            width: targetSize.width,
            height: sourceSize.height * (targetSize.width / sourceSize.width)
        )
    }
}

func fitSourceInsideTarget(sourceSize: CGSize, targetSize: CGSize) -> CGRect {
    let fitSize = resizeSourceToFitInsideTarget(sourceSize: sourceSize, targetSize: targetSize)
    let offset = CGPoint(x: (targetSize.width - fitSize.width)/2, y: (targetSize.height - fitSize.height)/2)
    return CGRect(origin: offset, size: fitSize)
}

func resizeSourceToFillInsideTarget(sourceSize: CGSize, targetSize: CGSize) -> CGSize {
    let sourceResolution = sourceSize.width / sourceSize.height
    let targetResolution = targetSize.width / targetSize.height
    if targetResolution < sourceResolution {
        return CGSize(
            width: sourceSize.width * (targetSize.height / sourceSize.height),
            height: targetSize.height
        )
    }
    else {
        return CGSize(
            width: targetSize.width,
            height: sourceSize.height * (targetSize.width / sourceSize.width)
        )
    }
}

func fillSourceInsideTarget(sourceSize: CGSize, targetSize: CGSize) -> CGRect {
    let fitSize = resizeSourceToFillInsideTarget(sourceSize: sourceSize, targetSize: targetSize)
    let offset = CGPoint(x: (targetSize.width - fitSize.width)/2, y: (targetSize.height - fitSize.height)/2)
    return CGRect(origin: offset, size: fitSize)
}

func scaleWithMatrix(inputDimensions: CGSize, outputDimensions: CGSize) -> GLKMatrix4 {
    var scale = CGSize()
    let aspectRatio = CGSize(width: outputDimensions.width / inputDimensions.width, height: outputDimensions.height / inputDimensions.height)
    if aspectRatio.height > aspectRatio.width {
        scale.width = outputDimensions.width / (inputDimensions.width * aspectRatio.height)
        scale.height = 1.0
    }
    else {
        scale.width = 1.0
        scale.height = outputDimensions.height / (inputDimensions.height * aspectRatio.width)
    }
    return GLKMatrix4MakeScale(scale.width.f, scale.height.f, 0)
}
