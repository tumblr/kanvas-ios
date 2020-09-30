//
//  NumTypes+Conversion.swift
//  OOPUtils
//
//  Created by OOPer in cooperation with shlab.jp, on 2014/12/31.
//
//
/*
Copyright (c) 2015, OOPer(NAGATA, Atsuyuki)
All rights reserved.

Use of any parts(functions, classes or any other program language components)
of this file is permitted with no restrictions, unless you
redistribute or use this file in its entirety without modification.
In this case, providing any sort of warranties or not is the user's responsibility.

Redistribution and use in source and/or binary forms, without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit

//GLboolean, Boolean
extension UInt8: ExpressibleByBooleanLiteral {
    public var boolValue: Bool {
        return self != 0
    }
    public init(booleanLiteral value: BooleanLiteralType) {
        self = value ? UInt8(1) : UInt8(0)
    }
}
//GLint
extension Int32: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = value ? Int32(1) : Int32(0)
    }
}

//long
extension Int {
    public var g: CGFloat {
        return CGFloat(self)
    }
    public var d: Double {
        return Double(self)
    }
    public var f: Float {
        return Float(self)
    }
    public var b: Int8 {
        return Int8(self)
    }
    public var ub: UInt8 {
        return UInt8(self)
    }
    public var s: Int16 {
        return Int16(self)
    }
    public var us: UInt16 {
        return UInt16(self)
    }
    public var i: Int32 {
        return Int32(self)
    }
    public var ui: UInt32 {
        return UInt32(self)
    }
//    public var l: Int {
//        return Int(self)
//    }
    public var ul: UInt {
        return UInt(self)
    }
    public var ll: Int64 {
        return Int64(self)
    }
    public var ull: UInt64 {
        return UInt64(self)
    }
}

//unsigned long, size_t
extension UInt {
    public var g: CGFloat {
        return CGFloat(self)
    }
    public var d: Double {
        return Double(self)
    }
    public var f: Float {
        return Float(self)
    }
    public var b: Int8 {
        return Int8(self)
    }
    public var ub: UInt8 {
        return UInt8(self)
    }
    public var s: Int16 {
        return Int16(self)
    }
    public var us: UInt16 {
        return UInt16(self)
    }
    public var i: Int32 {
        return Int32(self)
    }
    public var ui: UInt32 {
        return UInt32(self)
    }
    public var l: Int {
        return Int(self)
    }
//    public var ul: UInt {
//        return UInt(self)
//    }
    public var ll: Int64 {
        return Int64(self)
    }
    public var ull: UInt64 {
        return UInt64(self)
    }
}

//GLint, cl_int
extension Int32 {
    public var g: CGFloat {
        return CGFloat(self)
    }
    public var d: Double {
        return Double(self)
    }
    public var f: Float {
        return Float(self)
    }
    public var b: Int8 {
        return Int8(self)
    }
    public var ub: UInt8 {
        return UInt8(self)
    }
    public var s: Int16 {
        return Int16(self)
    }
    public var us: UInt16 {
        return UInt16(self)
    }
//    public var i: Int32 {
//        return Int32(self)
//    }
    public var ui: UInt32 {
        return UInt32(self)
    }
    public var l: Int {
        return Int(self)
    }
    public var ul: UInt {
        return UInt(self)
    }
    public var ll: Int64 {
        return Int64(self)
    }
    public var ull: UInt64 {
        return UInt64(self)
    }
}

//GLuint, GLenum, GLsizei
extension UInt32 {
    public var g: CGFloat {
        return CGFloat(self)
    }
    public var d: Double {
        return Double(self)
    }
    public var f: Float {
        return Float(self)
    }
    public var b: Int8 {
        return Int8(self)
    }
    public var ub: UInt8 {
        return UInt8(self)
    }
    public var s: Int16 {
        return Int16(self)
    }
    public var us: UInt16 {
        return UInt16(self)
    }
    public var i: Int32 {
        return Int32(self)
    }
//    public var ui: UInt32 {
//        return UInt32(self)
//    }
    public var l: Int {
        return Int(self)
    }
    public var ul: UInt {
        return UInt(self)
    }
    public var ll: Int64 {
        return Int64(self)
    }
    public var ull: UInt64 {
        return UInt64(self)
    }
}

//Darwin clock_types.h
extension UInt64 {
    public var g: CGFloat {
        return CGFloat(self)
    }
    public var d: Double {
        return Double(self)
    }
    public var f: Float {
        return Float(self)
    }
    public var b: Int8 {
        return Int8(self)
    }
    public var ub: UInt8 {
        return UInt8(self)
    }
    public var s: Int16 {
        return Int16(self)
    }
    public var us: UInt16 {
        return UInt16(self)
    }
    public var i: Int32 {
        return Int32(self)
    }
    public var ui: UInt32 {
        return UInt32(self)
    }
    public var l: Int {
        return Int(self)
    }
        public var ul: UInt {
            return UInt(self)
        }
    public var ll: Int64 {
        return Int64(self)
    }
//    public var ull: UInt64 {
//        return UInt64(self)
//    }
}

//GLfloat, cl_float
extension Float {
    public var g: CGFloat {
        return CGFloat(self)
    }
    public var d: Double {
        return Double(self)
    }
}

extension Double {
    public var g: CGFloat {
        return CGFloat(self)
    }
    public var f: Float {
        return Float(self)
    }
}

extension CGFloat {
    public var d: Double {
        return Double(self)
    }
    public var f: Float {
        return Float(self)
    }
    public var i: Int32 {
        return Int32(self)
    }
}
