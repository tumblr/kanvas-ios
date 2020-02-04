//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import OpenGLES
import UIKit

public struct GLU {

    /// Compile a shader from the provided source(s)
    @discardableResult
    public static func compileShader(_ target: GLenum, _ count: GLsizei, _ sources: UnsafePointer<UnsafePointer<GLchar>?>, _ shader: inout GLuint) -> GLint
    {
        var status: GLint = 0
        
        shader = glCreateShader(target)
        glShaderSource(shader, count, sources, nil)
        glCompileShader(shader)

        glGetShaderiv(shader, GL_COMPILE_STATUS.ui, &status)
        #if DEBUG
        if status == 0 {
            let length = 256
            var infoLog = [CChar](repeating: CChar(0), count: length)
            var l = GLsizei(0)
            glGetShaderInfoLog(shader, length.i, &l, &infoLog)
            if l > 0 {
                let message = String.init(utf8String: infoLog)
                let shaderType = target == GL_FRAGMENT_SHADER ? "Fragment" : "Vertex"
                assertionFailure("\(shaderType) shader compile: \(message ?? "No log")")
            }
        }
        #endif
        
        return status
    }
    
    
    /// Link a program with all currently attached shaders
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
            var l = GLsizei(0)
            let length = 256
            var infoLog = [CChar](repeating: CChar(0), count: length)
            glGetProgramInfoLog(program, length.i, &l, &infoLog)
            if l > 0 {
                let message = String.init(utf8String: infoLog)
                assertionFailure("Failed to link program: \(message ?? "No Log")")
            }
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
            assertionFailure("Failed to validate program \(program)")
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
            glDetachShader(prog, vertShader)
            glDeleteShader(vertShader)
        }
        if fragShader != 0 {
            glDetachShader(prog, fragShader)
            glDeleteShader(fragShader)
        }
        
        return status
    }

}
