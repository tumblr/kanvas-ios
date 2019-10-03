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

    var matrixOverride: GLKMatrix4?

    static func abc() -> UnsafePointer<GLfloat> {
        var tmp: [GLfloat] = [
            1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0,
        ]
        let components = MemoryLayout.size(ofValue: tmp)/MemoryLayout.size(ofValue: tmp[0])
        return withUnsafePointer(to: &tmp) {
            return $0.withMemoryRebound(to: GLfloat.self, capacity: components) {
                return $0
            }
        }
    }

    static var identity: GLKMatrix4 {
        return GLKMatrix4Identity
    }

    static var transformationMatrixIdentity: UnsafePointer<GLfloat> {
//        let t = Transformation(depth: 0, scale: .init(v: (1.0, 1.0)), translation: .init(v: (0.0, 0.0)), rotation: .init(v: (0.0,0.0,0.0)))
//        return t.transformationMatrixArray
        var mat = GLKMatrix4Identity
        let res = GL_GLKMatrix4Pointer(&mat)!
        return UnsafePointer<GLfloat>(res)
    }

    init(matrix: GLKMatrix4) {
        matrixOverride = matrix
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

    var transformationMatrix: GLKMatrix4 {
        guard matrixOverride == nil else {
            return matrixOverride!
        }
        var modelView = GLKMatrix4Identity
        let quaternion = GLKMatrix4MakeWithQuaternion(rotationEnd)
        modelView = GLKMatrix4Translate(modelView, translationEnd.x, translationEnd.y, -depth)
        modelView = GLKMatrix4Multiply(modelView, quaternion)
        modelView = GLKMatrix4Scale(modelView, scaleEnd.x, scaleEnd.y, -depth)
        return modelView
    }

    var transformationMatrixArray: UnsafePointer<GLfloat> {
        let tmp = transformationMatrix.m
        var tmp2 = Array<GLfloat>.init(repeating: 0.0, count: 16)
        tmp2[0] = tmp.0
        tmp2[1] = tmp.1
        tmp2[2] = tmp.2
        tmp2[3] = tmp.3
        tmp2[4] = tmp.4
        tmp2[5] = tmp.5
        tmp2[6] = tmp.6
        tmp2[7] = tmp.7
        tmp2[8] = tmp.8
        tmp2[9] = tmp.9
        tmp2[10] = tmp.10
        tmp2[11] = tmp.11
        tmp2[12] = tmp.12
        tmp2[13] = tmp.13
        tmp2[14] = tmp.14
        tmp2[15] = tmp.15
        var pointer = UnsafeMutablePointer<GLfloat>.allocate(capacity: 1)
        pointer.pointee = tmp2[0]
        return UnsafePointer(pointer)
//        let count = MemoryLayout.size(ofValue: tmp)/MemoryLayout.size(ofValue: tmp.0)
//        return UnsafeBufferPointer(start: &tmp.0, count: count)
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
