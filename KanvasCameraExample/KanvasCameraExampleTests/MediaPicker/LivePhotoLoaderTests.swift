//
//  LivePhotoLoaderTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 8/12/20.
//  Copyright © 2020 Tumblr. All rights reserved.
//

import Foundation

import XCTest

import Photos
@testable import KanvasCamera

final class LivePhotoLoaderTests: XCTestCase {
    func test() {
        let asset = PHAsset()
        let _ = LivePhotoLoader(asset: asset)
    }
}
