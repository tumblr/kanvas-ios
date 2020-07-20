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

kernel void mirror4(texture2d<float, access::read> inTexture [[ texture(0) ]],
                    texture2d<float, access::write> outTexture [[ texture(1) ]],
                    uint2 gid [[ thread_position_in_grid ]])
{
    uint width = inTexture.get_width();
    uint height = inTexture.get_height();
    
    float4 outColor;
    // bottom right
    if (gid.x >= width / 2 && gid.y >= height / 2) {
        outColor = inTexture.read(gid);
    }
    // bottom left
    else if (gid.x < width / 2 && gid.y >= height / 2) {
        outColor = inTexture.read(uint2(width - gid.x, gid.y));
    }
    // top right
    else if (gid.x >= width / 2 && gid.y < height / 2) {
        outColor = inTexture.read(uint2(gid.x, height - gid.y));
    }
    // top left
    else {
        outColor = inTexture.read(uint2(width - gid.x, height - gid.y));
    }
    outTexture.write(outColor, gid);
}

#define TAU 6.28318530718
#define MAX_ITER 5
kernel void wavepool(texture2d<float, access::read> inTexture [[ texture(0) ]],
                     texture2d<float, access::write> outTexture [[ texture(1) ]],
                     constant ShaderContext &shaderContext [[ buffer(0) ]],
                     uint2 gid [[ thread_position_in_grid ]])
{
    float time = shaderContext.time;
    float width = inTexture.get_width();
    float height = inTexture.get_height();
    float2 uv = float2(gid.x / width, gid.y / height);
    
    float2 p =  fmod(uv * TAU * 2, TAU) - 250.0;
    float2 i = float2(p);
    float c = 1.0;
    float inten = 0.005;
    
    for (int n = 0; n < MAX_ITER; n++) {
        float t = time * (1.0 - (3.5 / float(n + 1)));
        i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
        c += 1.0 / length(float2(p.x / (sin(i.x + t) / inten), p.y / (cos(i.y + t) / inten)));
    }
    c /= float(MAX_ITER);
    c = 1.17 - pow(c, 1.4);
    float3 color = float3(pow(abs(c), 8.0));
    color = clamp(color + float3(0.0, 0.35, 0.5), 0.0, 1.0);
    
    float4 outColor = float4(color, 1.0);
    float stongth = 0.3;
    float waveu = sin((uv.y + time) * 20.0) * 0.5 * 0.05 * stongth;
    float4 textureColor = inTexture.read(gid + uint2(waveu * width, 0));
    
    outColor.r = (outColor.r + (textureColor.r * 1.3)) / 2.0;
    outColor.g = (outColor.g + (textureColor.g * 1.3)) / 2.0;
    outColor.b = (outColor.b + (textureColor.b * 1.3)) / 2.0;
    outColor.a = 1.0;
    
    outTexture.write(outColor, gid);
}

#define W float3(0.2125, 0.7154, 0.0721)
kernel void grayscale(texture2d<float, access::read> inTexture [[ texture(0) ]],
                      texture2d<float, access::write> outTexture [[ texture(1) ]],
                      uint2 gid [[ thread_position_in_grid ]])
{
    float4 inColor = inTexture.read(gid);
    float gray = dot(inColor.rgb, W);
    float4 outColor(gray, gray, gray, 1.0);
    outTexture.write(outColor, gid);
}

kernel void lightLeaks(texture2d<float, access::read> inTexture [[ texture(0) ]],
                       texture2d<float, access::write> outTexture [[ texture(1) ]],
                       constant ShaderContext &shaderContext [[ buffer(0) ]],
                       uint2 gid [[ thread_position_in_grid ]])
{
    float time = shaderContext.time;
    float width = inTexture.get_width();
    float height = inTexture.get_height();
    float2 p = float2(gid.x / width, gid.y / height);
    float4 cam = inTexture.read(gid);
    
    for (int i = 1; i < 6; i++) {
        float2 newp = p;
        newp.x += 0.6 / float(i) * cos(float(i) * p.y + (time * 7.0) / 10.0 + 0.3 * float(i)) + 400. / 20.0;
        newp.y += 0.6 / float(i) * cos(float(i) * p.x + (time * 5.0) / 10.0 + 0.3 * float(i + 10)) - 400. / 20.0 + 15.0;
        p = newp;
    }
    float4 col = float4(2.0 * sin(3.0 * p.x) + 0.7, 1.2 * sin(3.0 * p.y) + 0.7, 3.0 * sin(p.x + p.y)+0.4, sin(1.0));
    float alphaDivisor = cam.a + step(cam.a, 0.2);
    float4 outColor = cam * (col.a * (cam / alphaDivisor)
                            + (1.5 * col * (1.0 - (cam / alphaDivisor))))
                            + col * (1.0 - cam.a) + cam * (1.0 - col.a);
    outTexture.write(outColor, gid);
}
