//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import OpenGLES
import UIKit

/// This is a container for a texture initialized from an image
struct GLTexture {
    private(set) var textureID: GLuint = 0
    private(set) var width: Int = 0
    private(set) var height: Int = 0
    
    init(textureID: GLuint,
         width: Int,
         height: Int) {
        self.textureID = textureID
        self.width = width
        self.height = height
    }
    
    /// Convenience function for creating a texture from a UIImage
    ///
    /// - Parameter sourceImage: UIImage
    static func textureWithImage(_ sourceImage: UIImage?) -> GLTexture? {
        guard let sourceImage = sourceImage, let textureImage = sourceImage.cgImage, let colorSpace = textureImage.colorSpace else {
            NSLog("Failed to load image")
            return nil
        }
        
        let width = GLsizei(textureImage.width)
        let height = GLsizei(textureImage.height)
        let textureData = UnsafeMutablePointer<GLubyte>.allocate(capacity: Int(width * height * 4))
        if let spriteContext = CGContext(data: textureData,
                                         width: Int(width),
                                         height: Int(height),
                                         bitsPerComponent: 8,
                                         bytesPerRow: Int(width * 4),
                                         space: colorSpace,
                                         bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            spriteContext.setBlendMode(.copy)
            spriteContext.draw(textureImage, in: CGRect(x: 0, y: 0, width: CGFloat(Int(width)), height: CGFloat(Int(height))))
        }
        
        var texture = GLuint()
        glActiveTexture(GL_TEXTURE2.ui)
        glGenTextures(1, &texture)
        glBindTexture(GL_TEXTURE_2D.ui, texture)
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MIN_FILTER.ui, GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MAG_FILTER.ui, GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_S.ui, GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_T.ui, GL_CLAMP_TO_EDGE)
        glTexImage2D(GL_TEXTURE_2D.ui,
                     0, GL_RGBA, width, height, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), textureData)
        textureData.deallocate()
        
        if texture == 0 {
            NSLog("failed to load texture properly")
            return nil
        }
        
        return GLTexture(textureID: texture, width: Int(sourceImage.size.width), height: Int(sourceImage.size.height))
    }
    
    func deleteTexture() {
        if textureID != 0 {
            var texture = textureID
            glDeleteTextures(1, &texture)
        }
    }
}
