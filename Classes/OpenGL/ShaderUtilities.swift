//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import OpenGLES
import UIKit

enum BlendType: String {
    case alpha = "alpha_blend"
    case color = "color_blend"
    case overlay = "overlay_blend"
    case onlyFirst = "FirstTexturePassthrough"
    case onlySecond = "SecondTexturePassthrough"
    case fourTexture = "four_texture"
}

private func printf(_ format: String, args: [CVarArg]) {
    print(String(format: format, arguments: args), terminator: "")
}
private func printf(_ format: String, args: CVarArg...) {
    printf(format, args: args)
}
func LogInfo(_ format: String, args: CVarArg...) {
    printf(format, args: args)
}
func LogError(_ format: String, args: CVarArg...) {
    printf(format, args: args)
}

public struct glue {
    /* Compile a shader from the provided source(s) */
    @discardableResult
    public static func compileShader(_ target: GLenum, _ count: GLsizei, _ sources: UnsafePointer<UnsafePointer<GLchar>?>, _ shader: inout GLuint) -> GLint
    {
        var status: GLint = 0
        
        shader = glCreateShader(target)
        glShaderSource(shader, count, sources, nil)
        glCompileShader(shader)
        
        #if DEBUG
            var logLength: GLint = 0
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH.ui, &logLength)
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>.allocate(capacity: logLength.l)
                glGetShaderInfoLog(shader, logLength, &logLength, log)
                log.deallocate()
            }
        #endif
        
        glGetShaderiv(shader, GL_COMPILE_STATUS.ui, &status)
        if status == 0 {
            
            LogError("Failed to compile shader:\n")
            for i in 0..<count.l {
                if let source = sources[i] {
                    LogInfo("%s", args: OpaquePointer(source))
                }
            }
        }
        
        return status
    }
    
    
    /* Link a program with all currently attached shaders */
    public static func linkProgram(_ program: GLuint) -> GLint {
        var status: GLint = 0
        
        glLinkProgram(program)
        
        #if DEBUG
            var logLength: GLint = 0
            glGetProgramiv(program, GL_INFO_LOG_LENGTH.ui, &logLength)
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>.allocate(capacity: logLength.l)
            glGetProgramInfoLog(program, logLength, &logLength, log)
            log.deallocate()
            }
        #endif
        
        glGetProgramiv(program, GL_LINK_STATUS.ui, &status)
        if status == 0 {
            LogError("Failed to link program %d", args: program)
        }
        
        return status
    }
    
    
    /* Validate a program (for i.e. inconsistent samplers) */
    public static func validateProgram(_ program: GLuint) -> GLint {
        var status: GLint = 0
        
        glValidateProgram(program)
        
        #if DEBUG
            var logLength: GLint = 0
            glGetProgramiv(program, GL_INFO_LOG_LENGTH.ui, &logLength)
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>.allocate(capacity: logLength.l)
            glGetProgramInfoLog(program, logLength, &logLength, log)
            log.deallocate()
            }
        #endif
        
        glGetProgramiv(program, GL_VALIDATE_STATUS.ui, &status)
        if status == 0 {
            LogError("Failed to validate program %d", args: program)
        }
        
        return status
    }
    
    
    /* Return named uniform location after linking */
    public static func getUniformLocation(_ program: GLuint, _ uniformName: String) -> GLint {
        
        let loc = glGetUniformLocation(program, uniformName)
        
        return loc
    }
    
    
    /* Convenience wrapper that compiles, links, enumerates uniforms and attribs */
    @discardableResult
    public static func createProgram(_ _vertSource: UnsafePointer<GLchar>?,
        _ _fragSource: UnsafePointer<GLchar>?,
        _ attribNames: [String],
        _ attribLocations: [GLuint],
        _ uniformNames: [String],
        _ uniformLocations: inout [GLint],
        _ program: inout GLuint) -> GLint
    {
        var vertShader: GLuint = 0, fragShader: GLuint = 0, prog: GLuint = 0, status: GLint = 1
        
        // Create shader program
        prog = glCreateProgram()
        
        // Create and compile vertex shader
        var vertSource = _vertSource
        status *= compileShader(GL_VERTEX_SHADER.ui, 1, &vertSource, &vertShader)
        
        // Create and compile fragment shader
        var fragSource = _fragSource
        status *= compileShader(GL_FRAGMENT_SHADER.ui, 1, &fragSource, &fragShader)
        
        // Attach vertex shader to program
        glAttachShader(prog, vertShader)
        
        // Attach fragment shader to program
        glAttachShader(prog, fragShader)
        
        // Bind attribute locations
        // This needs to be done prior to linking
        for i in 0..<attribNames.count {
            if !attribNames[i].isEmpty {
                glBindAttribLocation(prog, attribLocations[i], attribNames[i])
            }
        }
        
        // Link program
        status *= linkProgram(prog)
        
        // Get locations of uniforms
        if status != 0 {
            for i in 0..<uniformNames.count {
                if !uniformNames[i].isEmpty {
                    uniformLocations[i] = getUniformLocation(prog, uniformNames[i])
                }
            }
            program = prog
        }
        
        // Release vertex and fragment shaders
        if vertShader != 0 {
            glDeleteShader(vertShader)
        }
        if fragShader != 0 {
            glDeleteShader(fragShader)
        }
        
        return status
    }
    
    static func textureToImage(texture: GLTexture) -> UIImage? {
        let width = texture.width
        let height = texture.height
        let size = width * height * 4
        let data = CFDataCreateMutable(kCFAllocatorDefault, size)
        guard let textureData = data else {
            return nil
        }
        CFDataSetLength(textureData, size)
        
        let bitsPerComponent: Int = 8
        let bitsPerPixel: Int = 32
        let bytesPerRow: Int = 4 * width
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let renderingIntent = CGColorRenderingIntent.defaultIntent
        if let provider = CGDataProvider(data: textureData) {
            if let cgImage = CGImage(width: width,
                                     height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bitsPerPixel: bitsPerPixel,
                                     bytesPerRow: bytesPerRow,
                                     space: colorSpaceRef,
                                     bitmapInfo: bitmapInfo,
                                     provider: provider,
                                     decode: nil,
                                     shouldInterpolate: true,
                                     intent: renderingIntent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}
