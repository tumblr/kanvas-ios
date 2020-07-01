//
//  types.h
//  KanvasCamera
//
//  Created by Taichi Matsumoto on 7/1/20.
//

#ifndef types_h
#define types_h

struct ShaderContext {
    float time;
};

typedef struct {
    float4 renderedCoordinate [[position]];
    float2 textureCoordinate;
} TextureMappingVertex;

#endif /* types_h */
