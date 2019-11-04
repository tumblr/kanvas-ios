//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
