varying lowp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D textureOverlay;

uniform lowp vec2 overlayScale;

void main()
{
    lowp float overflowX = (1. - overlayScale.x) / 2.;
    lowp vec2 rangeX = vec2(overflowX, overlayScale.x + overflowX);
    lowp vec2 uv = vec2((textureCoordinate.x - rangeX.s) / (rangeX.t - rangeX.s), textureCoordinate.y);

    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    lowp vec4 textureOverlayColor = texture2D(textureOverlay, uv);
    if (uv.x < 0. || uv.x >= 1.) {
        textureOverlayColor.a = 0.;
    }

    lowp float alpha = 1.;
    gl_FragColor = vec4(mix(textureColor.rgb, textureOverlayColor.rgb, textureOverlayColor.a * alpha), textureColor.a);
}
