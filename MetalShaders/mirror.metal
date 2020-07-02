//
//  mirror.metal
//  KanvasCamera
//
//  Created by Taichi Matsumoto on 7/2/20.
//

#include <metal_stdlib>
#include "types.h"
using namespace metal;

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
