//
//  GLKMatrix4+Unsafe.swift
//  KanvasCamera
//
//  Created by Jimmy Schementi on 10/27/19.
//

import Foundation
import GLKit

extension GLKMatrix4 {
    func unsafePointer(block: (UnsafePointer<GLfloat>) -> Void) {
        var m = self.m
        let components = MemoryLayout.size(ofValue: m)/MemoryLayout.size(ofValue: m.0)
        withUnsafePointer(to: &m) {
            $0.withMemoryRebound(to: GLfloat.self, capacity: components) {
                block($0)
            }
        }
    }
}
