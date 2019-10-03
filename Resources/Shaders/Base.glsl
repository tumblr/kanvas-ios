varying lowp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

void main()
{
    //mat4 transform = mat4(1.);
    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
}
