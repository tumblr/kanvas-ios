//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

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
