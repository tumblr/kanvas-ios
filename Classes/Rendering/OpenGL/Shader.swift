//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import OpenGLES

/// enum for the two types of shader extensions
///
/// - fragment: fragment shader extension
/// - vertex: vertex shader extension
enum ShaderExtension: String {
    case fragment = "glsl"
    case vertex = "vsh"
}

struct ShaderConstants {
    static let squareVertices: [GLfloat] = [
        -1.0, -1.0, // bottom left
        1.0, -1.0, // bottom right
        -1.0,  1.0, // top left
        1.0,  1.0, // top right
    ]
    static let textureVertices: [Float] = [
        0.0, 0.0, // bottom left
        1.0, 0.0, // bottom right
        0.0,  1.0, // top left
        1.0,  1.0, // top right
    ]

    static let attribVertex: GLuint = 0
    static let attribTexturePosition: GLuint = 1
    static let numAttributes: GLuint = 2
    static let retainedBufferCount = 4
    static let shaderDirectory = "OpenGLShaders"
}

/// A wrapper for fragment and vertex shaders. Creates the program as well
class Shader {
    private(set) var program: GLuint = 0
    private var uniforms: [String: GLint] = [:]
    
    init?(vertexShader: String, fragmentShader: String) {
        setProgram(vertexShader: vertexShader, fragmentShader: fragmentShader)
        if program == 0 {
            return nil
        }
    }

    /// Gets the shader source code
    ///
    /// - Parameters:
    ///   - name: The name of the filter
    ///   - type: fragment or vertex
    /// - Returns: The shader source code as a String
    class func getSourceCode(_ name: String, type: ShaderExtension) -> String? {
        let extString: String = type.rawValue
        guard let bundlePath = KanvasCameraStrings.bundlePath(for: Shader.self),
        let bundle = Bundle(path: bundlePath),
        let path = bundle.path(forResource: String("\(ShaderConstants.shaderDirectory)/\(name)"), ofType: extString) else {
                return nil
        }
        
        do {
            let source = try String(contentsOfFile: path, encoding: .utf8)
            return source
        }
        catch {
            return nil
        }
    }
    
    /// Creates a program given the vertex and fragment shaders
    ///
    /// - Parameters:
    ///   - vertexShader: vertex
    ///   - fragmentShader: fragment
    private func setProgram(vertexShader: String, fragmentShader: String) {
        // Load vertex and fragment shaders
        let attribLocation: [GLuint] = [
            UInt32(0), UInt32(1), UInt32(2)
            ]
        let attribName: [String] = [
            "position", "texturecoordinate", "transform"
            ]
        var uniformLocations: [GLint] = []
        
        GLU.createProgram(vertexShader,
                           fragmentShader,
                           attribName,
                           attribLocation,
                           [],
                           &uniformLocations,
                           &self.program)
    }
    
    /// Searches for the uniform handle in the program
    ///
    /// - Parameter name: the name of the uniform
    /// - Returns: a value corresponding to the location of the uniform (pointer)
    func getParameterLocation(name: String) -> GLint {
        var handle = glGetAttribLocation(program, name)
        if handle == -1 {
            handle = glGetUniformLocation(program, name)
        }
        return handle
    }
    
    /// activates the current program
    func useProgram() {
        glUseProgram(program)
    }
    
    /// Deletes and disables current program
    func deleteProgram() {
        if program != 0 {
            glDeleteProgram(program)
            program = 0
        }
    }
    
    /// Sets a float value in a fragment shader
    ///
    /// - Parameters:
    ///   - key: the name of the uniform
    ///   - value: the float
    func setFloatUniform(key: String, value: Float) {
        var location = uniforms[key]
        if location == nil {
            location = getParameterLocation(name: key)
            if let foundLocation = location {
                uniforms[key] = foundLocation
            }
        }
        if let location = location, location != -1 {
            glUniform1f(location, value)
        }
    }
    
    /// Sets a vector in a fragment shader
    ///
    /// - Parameters:
    ///   - key: the name of the uniform
    ///   - value: the vector
    func setFloat2Uniform(key: String, value: [Float]) {
        guard value.count == 2 else {
            return
        }
        var location = uniforms[key]
        if location == nil {
            location = getParameterLocation(name: key)
            if let foundLocation = location {
                uniforms[key] = foundLocation
            }
        }
        if let location = location, location != -1 {
            var vector: [GLfloat] = []
            vector.append(value[0])
            vector.append(value[1])
            glUniform2fv(location, 1, vector)
        }
    }
    
    /// Sets a Int value in a fragment shader
    ///
    /// - Parameters:
    ///   - key: the name of the uniform
    ///   - value: the int
    func setIntUniform(key: String, value: Int) {
        var location = uniforms[key]
        if location == nil {
            location = getParameterLocation(name: key)
            if let foundLocation = location {
                uniforms[key] = foundLocation
            }
        }
        if let location = location, location != -1 {
            glUniform1i(location, GLint(value))
        }
    }
}
