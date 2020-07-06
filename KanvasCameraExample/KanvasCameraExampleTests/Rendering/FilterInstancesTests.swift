//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

class FilterInstancesTests: XCTestCase {

    var glContext: EAGLContext?

    override func setUp() {
        super.setUp()

        glContext = EAGLContext(api: .openGLES3) ?? nil
    }

    func testChromaFilter() {
        _ = ChromaOpenGLFilter(glContext: glContext)
    }

    func testEmInterferenceFilter() {
        _ = EMInterferenceOpenGLFilter(glContext: glContext)
    }

    func testFilmFilter() {
        _ = FilmOpenGLFilter(glContext: glContext)
    }

    func testGrayscaleFilter() {
        _ = GrayscaleOpenGLFilter(glContext: glContext)
    }

    func testImagePoolFilter() {
        _ = ImagePoolOpenGLFilter(glContext: glContext)
    }
    func testLegoFilter() {
        _ = LegoOpenGLFilter(glContext: glContext)
    }
    func testLightLeaksFilter() {
        _ = LightLeaksOpenGLFilter(glContext: glContext)
    }
    func testMangaFilterr() {
        _ = MangaOpenGLFilter(glContext: glContext)
    }
    func testMirrorFourFilter() {
        _ = MirrorFourOpenGLFilter(glContext: glContext)
    }
    func testMirrorTwoFilter() {
        _ = MirrorTwoOpenGLFilter(glContext: glContext)
    }
    func testPlasmaFilter() {
        _ = PlasmaOpenGLFilter(glContext: glContext)
    }
    func testRGBFilter() {
        _ = RGBOpenGLFilter(glContext: glContext)
    }
    func testRaveFilter() {
        _ = RaveOpenGLFilter(glContext: glContext)
    }
    func testToonFilter() {
        _ = ToonOpenGLFilter(glContext: glContext)
    }
    func testGroupFilter() {
        _ = GroupOpenGLFilter(filters: [
                PlasmaOpenGLFilter(glContext: glContext),
                LegoOpenGLFilter(glContext: glContext),
            ])
    }
    func testAlphaBlendFilter() {
        let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png")
        if let image = path.flatMap({ UIImage(contentsOfFile: $0) }), let pixelBuffer = image.pixelBuffer() {
            _ = AlphaBlendFilter(glContext: glContext, pixelBuffer: pixelBuffer)
        }
    }
}
