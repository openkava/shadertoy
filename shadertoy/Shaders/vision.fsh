//
//  Shader.fsh
//  opengles
//
//  Created by ydf on 12-12-12.
//  Copyright (c) 2012年 ydf. All rights reserved.
//

precision mediump float;
varying lowp vec4 colorVarying;


uniform  float time ;
uniform  vec2 mouse ;
uniform  vec2 resolution ;

const float lineCount = 10.;
const float bias = 0.5;
const float sharpness = 4.0;
const float smoothness = 0.05;

float sharpen(float v, float dist)
{
    //return pow(v*0.5+0.5 + bias, sharpness);
    float d = smoothness + pow(1. - dist,4.) * 0.5;
    return smoothstep(0.5 - d,.5 + d, v);
}

void main( void ) {
    
	vec2 position = (( gl_FragCoord.xy / resolution.xy ) - vec2(0.5));// / vec2(resolution.y/resolution.x,1.0);
	vec4 color = vec4(1.0);
	vec2 abspos = abs(position * 2.);
	float depth = clamp(sqrt(abspos.y*abspos.y + abspos.x*abspos.x), 0., 2.);
	float lc = mix(lineCount*2., lineCount, depth);
	vec2 pos = mod((abspos*.5-.75) * lc + time*0.25, 1.);
    
	float mx = 0.5;
	float ao = 1.0;
	if (abs(position.x) > abs(position.y)) {
        //mx = smoothstep(0.45,.55, pos.x);
        mx = abs(1.-sharpen(abs(pos.x*2. - 1.), depth) - sharpen(abs(mod(abspos.y / abspos.x * lineCount * 0.5, 2.)-1.), abspos.x));
        //	  mx = sharpen(abs(pos.x*2. - 1.), depth);
        //mx = pos.x;
        //mx = step(mod(abspos.y / abspos.x * lineCount*0.5 + 0.25, 1.), 0.5);
        // mx = smoothstep(0.45,.55, mod(abspos.y / abspos.x * lineCount*0.5 + 0.25, 1.));
        //mx = smoothstep(0.45 + mx,.55 + mx, mod(abspos.y / abspos.x * lineCount * 0.5, 1. + mx));
        ao = 1. - abspos.y / abspos.x;
        ao *= clamp(abspos.x*abspos.x, 0., 1.);
	} else {
        mx = sharpen(abs(pos.y*2. - 1.), depth);
        ao = 1. - abspos.x / abspos.y;
        ao *= clamp(abspos.y*abspos.y, 0., 1.);
	}
	color.rgb = mix(vec3(0.1, 0.3, 0.1), vec3( .9, .3, 0.1 ), mx);
	color.rgb *= pow(ao, 0.35);
	gl_FragColor = color;
}
