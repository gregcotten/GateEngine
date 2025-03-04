/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenGL_GateEngine)
import OpenGL_GateEngine

class OpenGLGeometry: GeometryBackend, SkinnedGeometryBackend {
    let primitive: DrawFlags.Primitive
    let attributes: ContiguousArray<GeometryAttribute>
    let buffers: [GLuint]
    let indiciesCount: GLsizei
    
    required init(lines: RawLines) {
        self.primitive = .line
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        let buffers = glGenBuffers(count: 3)
        
        glBindBuffer(buffers[0], as: .array)
        glBufferData(lines.positions, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[1], as: .array)
        glBufferData(lines.colors, withUsage: .static, as: .array)
        
        glBindBuffer(buffers.last!, as: .elementArray)
        glBufferData(lines.indicies, withUsage: .static, as: .elementArray)
        
        self.buffers = buffers
        self.indiciesCount = GLsizei(lines.indicies.count)
        
#if GATEENGINE_DEBUG_RENDERING
        Game.shared.renderer.openGLCheckError()
#endif
    }
    
    required init(points: RawPoints) {
        self.primitive = .point
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        let buffers = glGenBuffers(count: 3)
        
        glBindBuffer(buffers[0], as: .array)
        glBufferData(points.positions, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[1], as: .array)
        glBufferData(points.colors, withUsage: .static, as: .array)
        
        glBindBuffer(buffers.last!, as: .elementArray)
        glBufferData(points.indicies, withUsage: .static, as: .elementArray)
        
        self.buffers = buffers
        self.indiciesCount = GLsizei(points.indicies.count)
        
#if GATEENGINE_DEBUG_RENDERING
        Game.shared.renderer.openGLCheckError()
#endif
    }
    
    required init(geometry: RawGeometry) {
        self.primitive = .triangle
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord0),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord1),
            .init(type: .float, componentLength: 3, shaderAttribute: .tangent),
            .init(type: .float, componentLength: 3, shaderAttribute: .normal),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        let buffers = glGenBuffers(count: 7)
        
        glBindBuffer(buffers[0], as: .array)
        glBufferData(geometry.positions, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[1], as: .array)
        glBufferData(geometry.uvSet1, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[2], as: .array)
        glBufferData(geometry.uvSet2, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[3], as: .array)
        glBufferData(geometry.tangents, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[4], as: .array)
        glBufferData(geometry.normals, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[5], as: .array)
        glBufferData(geometry.colors, withUsage: .static, as: .array)
        
        glBindBuffer(buffers.last!, as: .elementArray)
        glBufferData(geometry.indicies, withUsage: .static, as: .elementArray)
        
        self.buffers = buffers
        self.indiciesCount = GLsizei(geometry.indicies.count)
        
#if GATEENGINE_DEBUG_RENDERING
        Game.shared.renderer.openGLCheckError()
#endif
    }
    
    required init(geometry: RawGeometry, skin: Skin) {
        self.primitive = .triangle
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord0),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord1),
            .init(type: .float, componentLength: 3, shaderAttribute: .tangent),
            .init(type: .float, componentLength: 3, shaderAttribute: .normal),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
            .init(type: .uInt32, componentLength: 4, shaderAttribute: .jointIndicies),
            .init(type: .float, componentLength: 4, shaderAttribute: .jointWeights),
        ]
        
        let buffers = glGenBuffers(count: 9)
        
        glBindBuffer(buffers[0], as: .array)
        glBufferData(geometry.positions, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[1], as: .array)
        glBufferData(geometry.uvSet1, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[2], as: .array)
        glBufferData(geometry.uvSet2, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[3], as: .array)
        glBufferData(geometry.tangents, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[4], as: .array)
        glBufferData(geometry.normals, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[5], as: .array)
        glBufferData(geometry.colors, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[6], as: .array)
        glBufferData(skin.jointIndicies, withUsage: .static, as: .array)
        
        glBindBuffer(buffers[7], as: .array)
        glBufferData(skin.jointWeights, withUsage: .static, as: .array)
        
        glBindBuffer(buffers.last!, as: .elementArray)
        glBufferData(geometry.indicies, withUsage: .static, as: .elementArray)
        
        self.buffers = buffers
        self.indiciesCount = GLsizei(geometry.indicies.count)
        
#if GATEENGINE_DEBUG_RENDERING
        Game.shared.renderer.openGLCheckError()
#endif
    }
    
#if GATEENGINE_DEBUG_RENDERING || DEBUG
    func isDrawCommandValid(sharedWith backend: GeometryBackend) -> Bool {
        let backend = backend as! Self
        if indiciesCount != backend.indiciesCount {
            return false
        }
        if self.primitive != backend.primitive {
            return false
        }
        return true
    }
#endif
    
    deinit {
        glDeleteBuffers(buffers)
    }
}

#endif
