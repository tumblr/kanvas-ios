//
//  DrawingCanvas.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 24/07/2019.
//

import Foundation
import UIKit

protocol DrawingCanvasDelegate: class {
    func didBeginTouches()
    func didEndTouches()
}

/// View for the drawing tools that shows/hides the menus when touched
final class DrawingCanvas: UIView {
    
    weak var delegate: DrawingCanvasDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didBeginTouches()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didEndTouches()
    }
}
