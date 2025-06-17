import UIKit
import XCTest

func XCTAssertColorsEqual(
    _ actual: [UIColor],
    _ expected: [UIColor],
    accuracy: CGFloat,
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertEqual(actual.count, expected.count, "Color count mismatch", file: file, line: line)

    for (i, (a, e)) in zip(actual, expected).enumerated() {
        if !a.isClose(to: e, tolerance: accuracy) {
            XCTFail(
                """
                Color mismatch at index \(i):
                actual   = \(a.hexDescription)
                expected = \(e.hexDescription)
                delta    = (r:\(abs((a.components()?.r ?? 0)-(e.components()?.r ?? 0))),
                            g:\(abs((a.components()?.g ?? 0)-(e.components()?.g ?? 0))),
                            b:\(abs((a.components()?.b ?? 0)-(e.components()?.b ?? 0))))
                """,
                file: file,
                line: line
            )
        }
    }
}

extension UIColor {
    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
        return (r, g, b, a)
    }

    func isClose(to other: UIColor, tolerance: CGFloat = 0.02) -> Bool {
        guard let c1 = self.components(), let c2 = other.components() else { return false }
        return abs(c1.r - c2.r) <= tolerance &&
               abs(c1.g - c2.g) <= tolerance &&
               abs(c1.b - c2.b) <= tolerance &&
               abs(c1.a - c2.a) <= tolerance
    }

    var hexDescription: String {
        guard let c = self.components() else { return "invalid color" }
        let r = Int(c.r * 255)
        let g = Int(c.g * 255)
        let b = Int(c.b * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
