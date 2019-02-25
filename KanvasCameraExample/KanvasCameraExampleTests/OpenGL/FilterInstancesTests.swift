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
        _ = ChromaFilter(glContext: glContext)
    }

    func testEmInterferenceFilter() {
        _ = EMInterferenceFilter(glContext: glContext)
    }

    func testFilmFilter() {
        _ = FilmFilter(glContext: glContext)
    }

    func testGrayscaleFilter() {
        _ = GrayscaleFilter(glContext: glContext)
    }

    func testImagePoolFilter() {
        _ = ImagePoolFilter(glContext: glContext)
    }
    func testLegoFilter() {
        _ = LegoFilter(glContext: glContext)
    }
    func testLightLeaksFilter() {
        _ = LightLeaksFilter(glContext: glContext)
    }
    func testMangaFilterr() {
        _ = MangaFilter(glContext: glContext)
    }
    func testMirrorFourFilter() {
        _ = MirrorFourFilter(glContext: glContext)
    }
    func testMirrorTwoFilter() {
        _ = MirrorTwoFilter(glContext: glContext)
    }
    func testPlasmaFilter() {
        _ = PlasmaFilter(glContext: glContext)
    }
    func testRGBFilter() {
        _ = RGBFilter(glContext: glContext)
    }
    func testRaveFilter() {
        _ = RaveFilter(glContext: glContext)
    }
    func testToonFilter() {
        _ = ToonFilter(glContext: glContext)
    }
    func testWaveFilter() {
        _ = WaveFilter(glContext: glContext)
    }
    func testWavePoolFilter() {
        _ = WavePoolFilter(glContext: glContext)
    }
    func testGroupFilter() {
        _ = GroupFilter(filters: [
                WaveFilter(glContext: glContext),
                ImagePoolFilter(glContext: glContext),
            ])
    }
}
