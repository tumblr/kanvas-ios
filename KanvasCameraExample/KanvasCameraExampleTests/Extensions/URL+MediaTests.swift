//
//  URL+MediaTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 6/15/20.
//  Copyright © 2020 Tumblr. All rights reserved.
//

import Foundation

import XCTest
@testable import KanvasCamera

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
