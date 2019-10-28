//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GLKit

class Transformation {

    enum TransformationState {
        case new
        case scale
        case translation
        case rotation
    }

    var state: TransformationState?

    var right: GLKVector3
    var up: GLKVector3
    var front: GLKVector3

    var depth: Float

    var scaleStart: GLKVector2?
    var scaleEnd: GLKVector2

    var translationStart: GLKVector2?
    var translationEnd: GLKVector2

    var rotationStart: GLKVector3?
    var rotationEnd: GLKQuaternion

    static var identity: GLKMatrix4 {
        return GLKMatrix4Identity
    }

    init() {
        scaleEnd = GLKVector2Make(0.0, 0.0)
        translationEnd = GLKVector2Make(0.0, 0.0)
        rotationEnd = GLKQuaternionMake(0.0, 0.0, 0.0, 0.0)
        depth = 0
        right = GLKVector3Make(1.0, 0.0, 0.0)
        up = GLKVector3Make(0.0, 1.0, 0.0)
        front = GLKVector3Make(0.0, 0.0, 1.0)
    }

    init(depth z: Float, scale s: GLKVector2, translation t: GLKVector2, rotation r: GLKVector3) {
        right = GLKVector3Make(1.0, 0.0, 0.0)
        up = GLKVector3Make(0.0, 1.0, 0.0)
        front = GLKVector3Make(0.0, 0.0, 1.0)

        depth = z
        scaleStart = nil
        scaleEnd = s

        translationStart = nil
        translationEnd = t

        rotationStart = nil
        rotationEnd = GLKQuaternionIdentity
        rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(-r.x, right), rotationEnd)
        rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(-r.y, up), rotationEnd)
        rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(-r.z, front), rotationEnd)
    }

    var scale: GLKVector2 {
        return scaleEnd
    }

    var rotate: Float {
        return GLKQuaternionAngle(rotationEnd)
    }

    var translate: GLKVector2 {
        return translationEnd
    }

    var matrix: GLKMatrix4 {
        var modelView = GLKMatrix4Identity
        let quaternion = GLKMatrix4MakeWithQuaternion(rotationEnd)
        modelView = GLKMatrix4Translate(modelView, translationEnd.x, translationEnd.y, -depth)
        modelView = GLKMatrix4Multiply(modelView, quaternion)
        modelView = GLKMatrix4Scale(modelView, scaleEnd.x, scaleEnd.y, -depth)
        return modelView
    }

    func start() {
        state = .new
        scaleStart = scaleEnd
        translationStart = GLKVector2Make(0.0, 0.0)
        rotationStart = GLKVector3Make(0.0, 0.0, 0.0)
    }

    func scale(x: Float, y: Float) {
        guard let scaleStart = scaleStart else {
            return
        }

        state = .scale
        let s = GLKVector2Make(x, y)
        scaleEnd = GLKVector2Multiply(s, scaleStart)
    }

    func translate(_ t: GLKVector2, multiplier m: Float) {
        guard let translationStart = translationStart else {
            return
        }

        state = .translation

        let t = GLKVector2Multiply(GLKVector2MultiplyScalar(t, m), scaleEnd)

        let dx = translationEnd.x + (t.x - translationStart.x)
        let dy = translationEnd.y - (t.y - translationStart.y)

        translationEnd = GLKVector2Make(dx, dy)
        self.translationStart = GLKVector2Make(t.x, t.y)
    }

    func rotate(_ r: GLKVector3, multiplier m: Float) {
        guard let rotationStart = rotationStart else {
            return
        }

        self.state = .rotation

        let dx = r.x - rotationStart.x
        let dy = r.y - rotationStart.y
        let dz = r.z - rotationStart.z

        self.rotationStart = GLKVector3Make(r.x, r.y, r.z)
        rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(dx * m, up), rotationEnd)
        rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(dy * m, right), rotationEnd)
        rotationEnd = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(-dz, front), rotationEnd)
    }

}
