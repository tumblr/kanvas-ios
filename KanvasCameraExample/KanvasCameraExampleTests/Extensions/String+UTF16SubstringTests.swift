//
//  String+UTF16SubstringTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 11/20/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

import XCTest
@testable import KanvasCamera

class String_UTF16SubstringTests: XCTestCase {

    func testSubstringAscii() {
        let ascii = "hello, world"
        let asciiHello = String(ascii.substring(withUTF16Range: NSMakeRange(0, 5)))
        XCTAssertEqual(asciiHello, "hello")
        let asciiWorld = String(ascii.substring(withUTF16Range: NSMakeRange(8, 5)))
        XCTAssertEqual(asciiWorld, "world")
    }

    func testSubstringEmoji() {
        let withEmoji = "hello, world 👋"
        let waveUTF16Len = "👋".utf16.count
        let waveEmoji = String(withEmoji.substring(withUTF16Range: NSMakeRange("hello, world ".utf16.count, waveUTF16Len)))
        XCTAssertEqual(waveEmoji, "👋")
    }

    func testSubstringGrapheme() {
        let familyGrapheme = "👩‍👩‍👧‍👧"
        let familyUTF16Len = familyGrapheme.utf16.count
        let familyGraphemeAlso = String(familyGrapheme.substring(withUTF16Range: NSMakeRange(0, familyUTF16Len)))
        XCTAssertEqual(familyGraphemeAlso, "👩‍👩‍👧‍👧")
        let incompleteString = String(familyGrapheme.substring(withUTF16Range: NSMakeRange(0, 1)))
        XCTAssertEqual(incompleteString, nil)
        let onePerson = String(familyGrapheme.substring(withUTF16Range: NSMakeRange(0, 3)))
        XCTAssertEqual(onePerson, "👩‍")
        let twoPeople = String(familyGrapheme.substring(withUTF16Range: NSMakeRange(0, 5)))
        XCTAssertEqual(twoPeople, "👩‍👩")
        let twoPeopleOneKid = String(familyGrapheme.substring(withUTF16Range: NSMakeRange(0, 8)))
        XCTAssertEqual(twoPeopleOneKid, "👩‍👩‍👧")
    }

}
