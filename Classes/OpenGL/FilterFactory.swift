//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

enum FilterType: Int, CaseIterable {
    case passthrough = 0
    case emInterference

    func name() -> String {
        switch self {
        case .passthrough:
            return "None"
        case .emInterference:
            return "EM-Interference"
        }
    }
}

struct FilterFactory {
    
    static func createFilter(type: FilterType, glContext: EAGLContext?) -> FilterProtocol {
        var newFilter: FilterProtocol
        switch type {
        case .emInterference:
            newFilter = EMInterferenceFilter(glContext: glContext)
        default:
            newFilter = Filter(glContext: glContext)
        }
        return newFilter
    }
}
