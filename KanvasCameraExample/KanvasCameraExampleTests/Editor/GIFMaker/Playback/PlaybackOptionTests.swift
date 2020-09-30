//
//  PlaybackOptionTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 29/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class PlaybackOptionTests: XCTestCase {
    
    func testOptionType() {
        let option = PlaybackOption.loop
        XCTAssertEqual(option, .loop, "Playback option does not match")
    }
}
