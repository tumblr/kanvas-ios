//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

func sum(_ count: Int, _ values: [Int]) -> Int {
    var theSum = 0
    for i in 0..<count {
        theSum += values[i]
    }
    return theSum
}

func pairGCD(_ a: Int, _ b: Int) -> Int {
    var aa = a;
    var bb = b;
    if (aa < bb) {
        return pairGCD(bb, aa)
    }
    while (true) {
        let r = aa % bb
        if r == 0 {
            return bb
        }
        aa = b
        bb = r
    }
}

func vectorGCD(_ count: Int, _ values: [Int]) -> Int {
    var gcd = values[0]
    for i in 1..<count {
        gcd = pairGCD(values[i], gcd);
    }
    return gcd
}
