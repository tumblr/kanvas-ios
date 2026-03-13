//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// MMCQ (modified median cut quantization) algorithm from
/// the Leptonica library (http://www.leptonica.com/).
final class MMCQ {
    
    // Use only upper 5 bits of 8 bits
    private static let signalBits = 5
    private static let rightShift = 8 - signalBits
    private static let multiplier = 1 << rightShift
    private static let histogramSize = 1 << (3 * signalBits)
    private static let vboxLength = 1 << signalBits
    private static let fractionByPopulation = 0.75
    private static let maxIterations = 1000
    
    /// Get reduced-space color index for a pixel.
    ///
    /// - Parameters:
    ///   - red: the red value
    ///   - green: the green value
    ///   - blue: the blue value
    /// - Returns: the color index
    static func makeColorIndexOf(red: Int, green: Int, blue: Int) -> Int {
        return (red << (2 * signalBits)) + (green << signalBits) + blue
    }
    
    public struct Color {
        public var r: UInt8
        public var g: UInt8
        public var b: UInt8
        
        init(r: UInt8, g: UInt8, b: UInt8) {
            self.r = r
            self.g = g
            self.b = b
        }
        
        public func makeUIColor() -> UIColor {
            return UIColor(red: CGFloat(r) / CGFloat(255), green: CGFloat(g) / CGFloat(255), blue: CGFloat(b) / CGFloat(255), alpha: CGFloat(1))
        }
    }
    
    enum ColorChannel {
        case r
        case g
        case b
    }
    
    /// 3D color space box.
    class VBox {
        
        var rMin: UInt8
        var rMax: UInt8
        var gMin: UInt8
        var gMax: UInt8
        var bMin: UInt8
        var bMax: UInt8
        
        private let histogram: [Int]
        
        private var average: Color?
        private var volume: Int?
        private var count: Int?
        
        init(rMin: UInt8, rMax: UInt8, gMin: UInt8, gMax: UInt8, bMin: UInt8, bMax: UInt8, histogram: [Int]) {
            self.rMin = rMin
            self.rMax = rMax
            self.gMin = gMin
            self.gMax = gMax
            self.bMin = bMin
            self.bMax = bMax
            self.histogram = histogram
        }
        
        init(vbox: VBox) {
            self.rMin = vbox.rMin
            self.rMax = vbox.rMax
            self.gMin = vbox.gMin
            self.gMax = vbox.gMax
            self.bMin = vbox.bMin
            self.bMax = vbox.bMax
            self.histogram = vbox.histogram
        }
        
        func makeRange(min: UInt8, max: UInt8) -> CountableRange<Int> {
            if min <= max {
                return Int(min) ..< Int(max + 1)
            }
            else {
                return Int(max) ..< Int(max)
            }
        }
        
        var rRange: CountableRange<Int> { return makeRange(min: rMin, max: rMax) }
        var gRange: CountableRange<Int> { return makeRange(min: gMin, max: gMax) }
        var bRange: CountableRange<Int> { return makeRange(min: bMin, max: bMax) }
        
        /// Get 3 dimensional volume of the color space
        ///
        /// - Parameter force: force recalculate
        /// - Returns: the volume
        func getVolume(forceRecalculate force: Bool = false) -> Int {
            if let volume = volume, !force {
                return volume
            }
            else {
                let volume = (Int(rMax) - Int(rMin) + 1) * (Int(gMax) - Int(gMin) + 1) * (Int(bMax) - Int(bMin) + 1)
                self.volume = volume
                return volume
            }
        }
        
        /// Get total count of histogram samples
        ///
        /// - Parameter force: force recalculate
        /// - Returns: the volume
        func getCount(forceRecalculate force: Bool = false) -> Int {
            if let count = count, !force {
                return count
            }
            else {
                var count = 0
                for i in rRange {
                    for j in gRange {
                        for k in bRange {
                            let index = MMCQ.makeColorIndexOf(red: i, green: j, blue: k)
                            count += histogram[index]
                        }
                    }
                }
                self.count = count
                return count
            }
        }
        
        func getAverage(forceRecalculate force: Bool = false) -> Color {
            if let average = average, !force {
                return average
            }
            else {
                var ntot = 0
                
                var rSum = 0
                var gSum = 0
                var bSum = 0
                
                for i in rRange {
                    for j in gRange {
                        for k in bRange {
                            let index = MMCQ.makeColorIndexOf(red: i, green: j, blue: k)
                            let hval = histogram[index]
                            ntot += hval
                            rSum += Int(Double(hval) * (Double(i) + 0.5) * Double(MMCQ.multiplier))
                            gSum += Int(Double(hval) * (Double(j) + 0.5) * Double(MMCQ.multiplier))
                            bSum += Int(Double(hval) * (Double(k) + 0.5) * Double(MMCQ.multiplier))
                        }
                    }
                }
                
                let average: Color
                if ntot > 0 {
                    let r = UInt8(rSum / ntot)
                    let g = UInt8(gSum / ntot)
                    let b = UInt8(bSum / ntot)
                    average = Color(r: r, g: g, b: b)
                }
                else {
                    let r = UInt8(min(MMCQ.multiplier * (Int(rMin) + Int(rMax) + 1) / 2, 255))
                    let g = UInt8(min(MMCQ.multiplier * (Int(gMin) + Int(gMax) + 1) / 2, 255))
                    let b = UInt8(min(MMCQ.multiplier * (Int(bMin) + Int(bMax) + 1) / 2, 255))
                    average = Color(r: r, g: g, b: b)
                }
                
                self.average = average
                return average
            }
        }
        
        func widestColorChannel() -> ColorChannel {
            let rWidth = rMax - rMin
            let gWidth = gMax - gMin
            let bWidth = bMax - bMin
            switch max(rWidth, gWidth, bWidth) {
            case rWidth:
                return .r
            case gWidth:
                return .g
            default:
                return .b
            }
        }
        
    }
    
    /// Color map.
    open class ColorMap {
        
        var vboxes = [VBox]()
        
        func push(_ vbox: VBox) {
            vboxes.append(vbox)
        }
        
        open func makePalette() -> [Color] {
            return vboxes.map { $0.getAverage() }
        }
        
        open func makeNearestColor(to color: Color) -> Color {
            var nearestDistance = Int.max
            var nearestColor = Color(r: 0, g: 0, b: 0)
            
            for vbox in vboxes {
                let vbColor = vbox.getAverage()
                let dr = abs(Int(color.r) - Int(vbColor.r))
                let dg = abs(Int(color.g) - Int(vbColor.g))
                let db = abs(Int(color.b) - Int(vbColor.b))
                let distance = dr + dg + db
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestColor = vbColor
                }
            }
            
            return nearestColor
        }
    }
    
    /// Histo (1-d array, giving the number of pixels in each quantized region of color space), or null on error.
    private static func makeHistogramAndVBox(from pixels: [UInt8], quality: Int, ignoreWhite: Bool) -> ([Int], VBox) {
        var histogram = [Int](repeating: 0, count: histogramSize)
        var rMin = UInt8.max
        var rMax = UInt8.min
        var gMin = UInt8.max
        var gMax = UInt8.min
        var bMin = UInt8.max
        var bMax = UInt8.min
        
        let pixelCount = pixels.count / 4
        for i in stride(from: 0, to: pixelCount, by: quality) {
            let a = pixels[i * 4 + 0]
            let b = pixels[i * 4 + 1]
            let g = pixels[i * 4 + 2]
            let r = pixels[i * 4 + 3]
            
            // If pixel is not mostly opaque or white
            guard a >= 125 && !(ignoreWhite && r > 250 && g > 250 && b > 250) else {
                continue
            }
            
            let shiftedR = r >> UInt8(rightShift)
            let shiftedG = g >> UInt8(rightShift)
            let shiftedB = b >> UInt8(rightShift)
            
            // find min/max
            rMin = min(rMin, shiftedR)
            rMax = max(rMax, shiftedR)
            gMin = min(gMin, shiftedG)
            gMax = max(gMax, shiftedG)
            bMin = min(bMin, shiftedB)
            bMax = max(bMax, shiftedB)
            
            // increment histgram
            let index = MMCQ.makeColorIndexOf(red: Int(shiftedR), green: Int(shiftedG), blue: Int(shiftedB))
            histogram[index] += 1
        }
        
        let vbox = VBox(rMin: rMin, rMax: rMax, gMin: gMin, gMax: gMax, bMin: bMin, bMax: bMax, histogram: histogram)
        return (histogram, vbox)
    }
    
    private static func applyMedianCut(with histogram: [Int], vbox: VBox) -> [VBox] {
        guard vbox.getCount() != 0 else {
            return []
        }
        
        // only one pixel, no split
        guard vbox.getCount() != 1 else {
            return [vbox]
        }
        
        // Find the partial sum arrays along the selected axis.
        var total = 0
        var partialSum = [Int](repeating: -1, count: vboxLength) // -1 = not set / 0 = 0
        
        let axis = vbox.widestColorChannel()
        switch axis {
        case .r:
            for i in vbox.rRange {
                var sum = 0
                for j in vbox.gRange {
                    for k in vbox.bRange {
                        let index = MMCQ.makeColorIndexOf(red: i, green: j, blue: k)
                        sum += histogram[index]
                    }
                }
                total += sum
                partialSum[i] = total
            }
        case .g:
            for i in vbox.gRange {
                var sum = 0
                for j in vbox.rRange {
                    for k in vbox.bRange {
                        let index = MMCQ.makeColorIndexOf(red: j, green: i, blue: k)
                        sum += histogram[index]
                    }
                }
                total += sum
                partialSum[i] = total
            }
        case .b:
            for i in vbox.bRange {
                var sum = 0
                for j in vbox.rRange {
                    for k in vbox.gRange {
                        let index = MMCQ.makeColorIndexOf(red: j, green: k, blue: i)
                        sum += histogram[index]
                    }
                }
                total += sum
                partialSum[i] = total
            }
        }
        
        var lookAheadSum = [Int](repeating: -1, count: vboxLength) // -1 = not set / 0 = 0
        for (i, sum) in partialSum.enumerated() where sum != -1 {
            lookAheadSum[i] = total - sum
        }
        
        return cut(by: axis, vbox: vbox, partialSum: partialSum, lookAheadSum: lookAheadSum, total: total)
    }
    
    private static func cut(by axis: ColorChannel, vbox: VBox, partialSum: [Int], lookAheadSum: [Int], total: Int) -> [VBox] {
        let vboxMin: Int
        let vboxMax: Int
        
        switch axis {
        case .r:
            vboxMin = Int(vbox.rMin)
            vboxMax = Int(vbox.rMax)
        case .g:
            vboxMin = Int(vbox.gMin)
            vboxMax = Int(vbox.gMax)
        case .b:
            vboxMin = Int(vbox.bMin)
            vboxMax = Int(vbox.bMax)
        }
        
        for i in vboxMin ... vboxMax where partialSum[i] > total / 2 {
            let vbox1 = VBox(vbox: vbox)
            let vbox2 = VBox(vbox: vbox)
            
            let left = i - vboxMin
            let right = vboxMax - i
            
            var d2: Int
            if left <= right {
                d2 = min(vboxMax - 1, i + right / 2)
            }
            else {
                // 2.0 and cast to int is necessary to have the same
                // behaviour as in JavaScript
                d2 = max(vboxMin, Int(Double(i - 1) - Double(left) / 2.0))
            }
            
            // avoid 0-count
            while d2 < 0 || partialSum[d2] <= 0 {
                d2 += 1
            }
            var count2 = lookAheadSum[d2]
            while count2 == 0 && d2 > 0 && partialSum[d2 - 1] > 0 {
                d2 -= 1
                count2 = lookAheadSum[d2]
            }
            
            // set dimensions
            switch axis {
            case .r:
                vbox1.rMax = UInt8(d2)
                vbox2.rMin = UInt8(d2 + 1)
            case .g:
                vbox1.gMax = UInt8(d2)
                vbox2.gMin = UInt8(d2 + 1)
            case .b:
                vbox1.bMax = UInt8(d2)
                vbox2.bMin = UInt8(d2 + 1)
            }
            
            return [vbox1, vbox2]
        }
        
        print("VBox can't be cut")
        return []
    }
    
    static func quantize(_ pixels: [UInt8], quality: Int, ignoreWhite: Bool, maxColors: Int) -> ColorMap? {
        // short-circuit
        guard !pixels.isEmpty && maxColors > 1 && maxColors <= 256 else {
            return nil
        }
        
        // get the histogram and the beginning vbox from the colors
        let (histogram, vbox) = makeHistogramAndVBox(from: pixels, quality: quality, ignoreWhite: ignoreWhite)
        
        // priority queue
        var pq = [vbox]
        
        // Round up to have the same behaviour as in JavaScript
        let target = Int(ceil(fractionByPopulation * Double(maxColors)))
        
        // first set of colors, sorted by population
        iterate(over: &pq, comparator: compareByCount, target: target, histogram: histogram)
        
        // Re-sort by the product of pixel occupancy times the size in color space.
        pq.sort(by: compareByProduct)
        
        // next set - generate the median cuts using the (npix * vol) sorting.
        iterate(over: &pq, comparator: compareByProduct, target: maxColors - pq.count, histogram: histogram)
        
        // Reverse to put the highest elements first into the color map
        pq = pq.reversed()
        
        // calculate the actual colors
        let colorMap = ColorMap()
        pq.forEach { colorMap.push($0) }
        return colorMap
    }
    
    // Inner function to do the iteration.
    private static func iterate(over queue: inout [VBox], comparator: (VBox, VBox) -> Bool, target: Int, histogram: [Int]) {
        var color = 1
        
        for _ in 0 ..< maxIterations {
            guard let vbox = queue.last else {
                return
            }
            
            if vbox.getCount() == 0 {
                queue.sort(by: comparator)
                continue
            }
            queue.removeLast()
            
            // do the cut
            let vboxes = applyMedianCut(with: histogram, vbox: vbox)
            queue.append(vboxes[0])
            if vboxes.count == 2 {
                queue.append(vboxes[1])
                color += 1
            }
            queue.sort(by: comparator)
            
            if color >= target {
                return
            }
        }
    }
    
    private static func compareByCount(_ a: VBox, _ b: VBox) -> Bool {
        return a.getCount() < b.getCount()
    }
    
    private static func compareByProduct(_ a: VBox, _ b: VBox) -> Bool {
        let aCount = a.getCount()
        let bCount = b.getCount()
        let aVolume = a.getVolume()
        let bVolume = b.getVolume()
        
        if aCount == bCount {
            // If count is 0 for both (or the same), sort by volume
            return aVolume < bVolume
        }
        else {
            // Otherwise sort by products
            let aProduct = Int64(aCount) * Int64(aVolume)
            let bProduct = Int64(bCount) * Int64(bVolume)
            return aProduct < bProduct
        }
    }
    
}
