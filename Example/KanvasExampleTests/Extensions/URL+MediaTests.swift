//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import XCTest
@testable import Kanvas

class URLMediaTests: XCTestCase {

    func testVideoURL() {
        do {
            let url = try URL.videoURL()
            XCTAssertTrue(url.lastPathComponent.hasPrefix("kanvas"))
            XCTAssertTrue(url.lastPathComponent.hasSuffix(".mp4"))
        } catch {
            XCTFail()
        }
    }

    func testImageURL() {
        do {
            let url = try URL.imageURL()
            XCTAssertTrue(url.lastPathComponent.hasPrefix("kanvas"))
            XCTAssertTrue(url.lastPathComponent.hasSuffix(".jpg"))
        } catch {
            XCTFail()
        }
    }

    func testInitializer() {
        do {
            let url = try URL(filename: "foo", fileExtension: "txt", unique: false, removeExisting: false)
            XCTAssertEqual(url.lastPathComponent, "foo.txt")
        }
        catch {
            XCTFail()
        }
    }

}
