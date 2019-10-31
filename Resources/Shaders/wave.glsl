precision highp float;

uniform sampler2D inputImageTexture;
uniform float time;
varying vec2 textureCoordinate;

void mainImage(out vec4 fragColor, in vec2 fragCoord ) {
	float stongth = 0.3;
	vec2 uv = fragCoord.xy;
	float waveu = sin((uv.y + time) * 20.0) * 0.5 * 0.05 * stongth;
	fragColor = texture2D(inputImageTexture, uv + vec2(waveu, 0));
}

void main() {
	mainImage(gl_FragColor, textureCoordinate);
}