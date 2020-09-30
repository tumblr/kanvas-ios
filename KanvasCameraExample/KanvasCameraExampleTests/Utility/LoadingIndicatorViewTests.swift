//
//  LoadingIndicatorViewTests.swift
//  EditorTestTests
//
//  Created by Daniela Riesgo on 30/08/2018.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//


@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class LoadingIndicatorViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newView() -> LoadingIndicatorView {
        let view = LoadingIndicatorView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }

    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }

    func testStartLoading() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.startLoading()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testStopLoading() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.startLoading()
        view.stopLoading()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testStartAfterStopLoading() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.startLoading()
        view.stopLoading()
        view.startLoading()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

}
