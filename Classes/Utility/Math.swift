//
//  Math.swift
//  KanvasCamera
//
//  Created by Jimmy Schementi on 5/4/20.
//

import Foundation

func sum(_ values: [Int]) -> Int {
    var result = 0
    for i in 0..<values.count {
        result += values[i]
    }
    return result
}

func pairGCD(_ a: Int, _ b: Int) -> Int {
    var aa = a
    var bb = b
    if aa < bb {
        return pairGCD(bb, aa)
    }
    while true {
        let r = aa % bb
        if r == 0 {
            return bb
        }
        aa = b
        bb = r
    }
}

func vectorGCD(_ values: [Int]) -> Int {
    var gcd = values[0]
    for i in 1..<values.count {
        gcd = pairGCD(values[i], gcd)
    }
    return gcd
}
