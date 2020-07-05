#include <metal_stdlib>
using namespace metal;

struct ShaderContext {
    float time;
};

typedef struct {
    float4 renderedCoordinate [[position]];
    float2 textureCoordinate;
} TextureMappingVertex;

//
// Shaders for render pipeline
//

vertex TextureMappingVertex vertexIdentity(unsigned int vertex_id [[ vertex_id ]])
{
    float4x4 renderedCoordinates = float4x4(float4( -1.0, -1.0, 0.0, 1.0 ),
                                            float4(  1.0, -1.0, 0.0, 1.0 ),
                                            float4( -1.0,  1.0, 0.0, 1.0 ),
                                            float4(  1.0,  1.0, 0.0, 1.0 ));

    float4x2 textureCoordinates = float4x2(float2( 0.0, 1.0 ),
                                           float2( 1.0, 1.0 ),
                                           float2( 0.0, 0.0 ),
                                           float2( 1.0, 0.0 ));
    TextureMappingVertex outVertex;
    outVertex.renderedCoordinate = renderedCoordinates[vertex_id];
    outVertex.textureCoordinate = textureCoordinates[vertex_id];
    
    return outVertex;
}

fragment half4 fragmentIdentity(TextureMappingVertex mappingVertex [[ stage_in ]],
                              texture2d<float, access::sample> texture [[ texture(0) ]])
{
    constexpr sampler s(address::clamp_to_edge, filter::linear);

    float4 color = texture.sample(s, mappingVertex.textureCoordinate);
    return half4(color);
}

//
// Shaders for compute pipeline
//

kernel void kernelIdentity(texture2d<float, access::read> inTexture [[ texture(0) ]],
                           texture2d<float, access::write> outTexture [[ texture(1) ]],
                           uint2 gid [[ thread_position_in_grid ]])
{
    float4 outColor = inTexture.read(gid);
    outTexture.write(outColor, gid);
}

kernel void mirror(texture2d<float, access::read> inTexture [[ texture(0) ]],
                   texture2d<float, access::write> outTexture [[ texture(1) ]],
                   uint2 gid [[ thread_position_in_grid ]])
{
    float4 outColor;
    uint width = inTexture.get_width();
    if (gid.x >= width / 2) {
        outColor = inTexture.read(gid);
    }
    else {
        outColor = inTexture.read(uint2(width - gid.x, gid.y));
    }
    outTexture.write(outColor, gid);
}
