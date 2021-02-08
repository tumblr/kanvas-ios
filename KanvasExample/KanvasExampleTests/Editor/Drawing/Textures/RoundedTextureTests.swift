//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class RoundedTextureTests: FBSnapshotTestCase {
    
    private let texture: Texture = RoundedTexture(minimumStroke: 10, maximumStroke: 20)
    private let blendMode: CGBlendMode = .normal
    private let drawingColor: UIColor = .blue
    private let strokeSize: CGFloat = 20
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        return imageView
    }
    
    func testDrawingPoint() {
        let imageView = newImageView()
        let startPoint = CGPoint(x: 100, y: 100)
        
        UIGraphicsBeginImageContext(imageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        texture.drawPoint(context: context, on: startPoint, size: strokeSize, blendMode: blendMode, color: drawingColor)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            imageView.image = image
        }
        UIGraphicsEndImageContext()
        
        FBSnapshotVerifyView(imageView)
    }
    
    func testDrawingLine() {
        let imageView = newImageView()
        let points = [
            CGPoint(x: 50, y: 50),
            CGPoint(x: 150, y: 150),
            CGPoint(x: 250, y: 250),
        ]
        
        UIGraphicsBeginImageContext(imageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        texture.drawLine(context: context, points: points, size: strokeSize, blendMode: blendMode, color: drawingColor)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            imageView.image = image
        }
        UIGraphicsEndImageContext()
        
        FBSnapshotVerifyView(imageView)
    }
}
