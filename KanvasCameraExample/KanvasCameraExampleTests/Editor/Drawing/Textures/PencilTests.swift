//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class PencilTests: FBSnapshotTestCase {
    
    private let texture: Texture = Pencil()
    private let blendMode: CGBlendMode = .normal
    private let drawingColor: UIColor = .blue
    private let strokeSize: CGFloat = 20
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return imageView
    }
    
    func testDrawingPoint() {
        let imageView = newImageView()
        let strokeSize = CGFloat(20)
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
        let startPoint = CGPoint(x: 100, y: 100)
        let endPoint = CGPoint(x: 200, y: 200)
        
        UIGraphicsBeginImageContext(imageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        texture.drawLine(context: context, from: startPoint, to: endPoint, size: strokeSize, blendMode: blendMode, color: drawingColor)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            imageView.image = image
        }
        UIGraphicsEndImageContext()
        
        FBSnapshotVerifyView(imageView)
    }
}
