//
//  ClosedRange+Clamp.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 26/10/2018.
//
extension ClosedRange {
    func clamp(_ value: Bound) -> Bound {
        // 'Swift.' is not necessary but it prevents a warning from showing
        return Swift.min(Swift.max(value, self.lowerBound), self.upperBound)
    }
}
